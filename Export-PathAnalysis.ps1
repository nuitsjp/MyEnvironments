<#
.SYNOPSIS
    Windows PATH環境変数を長い順でエクスポートするスクリプト

.DESCRIPTION
    現在のユーザー環境変数のPATHエントリを文字数の長い順にソートし、
    詳細な統計情報と共にファイルに出力します。PATH削減の参考資料として使用できます。

.PARAMETER OutputFile
    出力ファイル名（デフォルト: PATH_Analysis_yyyyMMdd_HHmmss.txt）

.PARAMETER IncludeSystem
    システム環境変数のPATHも含めて分析します

.PARAMETER ShowTop
    表示する上位エントリ数（デフォルト: 20）

.EXAMPLE
    .\Export-PathAnalysis.ps1
    デフォルト設定でPATH分析結果を出力

.EXAMPLE
    .\Export-PathAnalysis.ps1 -OutputFile "MyPathAnalysis.txt" -ShowTop 30
    カスタムファイル名で上位30件を出力

.EXAMPLE
    .\Export-PathAnalysis.ps1 -IncludeSystem
    システムPATHも含めて分析
#>

[CmdletBinding()]
param(
    [string]$OutputFile = "",
    [switch]$IncludeSystem,
    [int]$ShowTop = 20
)

function Get-PathStatistics {
    param(
        [string]$PathString,
        [string]$Type = "User"
    )
    
    if (-not $PathString) {
        return $null
    }
    
    $entries = $PathString -split ';' | Where-Object { $_ -ne "" }
    $duplicates = $entries | Group-Object | Where-Object { $_.Count -gt 1 }
    $existing = @()
    $nonExisting = @()
    
    foreach ($entry in $entries) {
        if ($entry -and $entry -ne "" -and $entry -ne "C") {
            if (Test-Path $entry) {
                $existing += $entry
            } else {
                $nonExisting += $entry
            }
        } elseif ($entry -eq "C") {
            $nonExisting += $entry
        }
    }
    
    return @{
        Type = $Type
        OriginalString = $PathString
        TotalLength = $PathString.Length
        Entries = $entries
        EntryCount = $entries.Count
        AverageLength = if ($entries.Count -gt 0) { [math]::Round($PathString.Length / $entries.Count, 1) } else { 0 }
        Duplicates = $duplicates
        DuplicateCount = $duplicates.Count
        ExistingPaths = $existing
        NonExistingPaths = $nonExisting
        LongestEntries = ($entries | Sort-Object Length -Descending)
        ShortestEntries = ($entries | Sort-Object Length)
        UniqueEntries = ($entries | Sort-Object -Unique)
    }
}

function Format-PathAnalysis {
    param(
        [object]$Stats,
        [int]$TopCount = 20
    )
    
    $output = @()
    $output += "=" * 80
    $output += "$($Stats.Type) PATH環境変数分析結果"
    $output += "分析日時: $(Get-Date -Format 'yyyy年MM月dd日 HH:mm:ss')"
    $output += "=" * 80
    $output += ""
    
    # 基本統計
    $output += "【基本統計】"
    $output += "総文字数: $($Stats.TotalLength) 文字"
    $output += "エントリ数: $($Stats.EntryCount) 個"
    $output += "平均エントリ長: $($Stats.AverageLength) 文字"
    $output += "重複エントリ数: $($Stats.DuplicateCount) 個"
    $output += "存在するパス: $($Stats.ExistingPaths.Count) 個"
    $output += "存在しないパス: $($Stats.NonExistingPaths.Count) 個"
    $output += "ユニークエントリ数: $($Stats.UniqueEntries.Count) 個"
    $output += ""
    
    # 制限との比較
    $output += "【Windows制限との比較】"
    $output += "個別環境変数制限: 2,047 文字"
    if ($Stats.TotalLength -le 2047) {
        $output += "ステータス: ✅ 制限内 (余裕: $(2047 - $Stats.TotalLength) 文字)"
    } else {
        $output += "ステータス: ❌ 制限超過 (超過: $($Stats.TotalLength - 2047) 文字)"
    }
    $output += ""
    
    # 最長・最短エントリ
    if ($Stats.LongestEntries.Count -gt 0) {
        $output += "【最長エントリ】"
        $output += "[$($Stats.LongestEntries[0].Length) 文字] $($Stats.LongestEntries[0])"
        $output += ""
        
        $output += "【最短エントリ】"
        $output += "[$($Stats.ShortestEntries[0].Length) 文字] $($Stats.ShortestEntries[0])"
        $output += ""
    }
    
    # 長いエントリ上位リスト
    $output += "【長いエントリ順 (上位 $TopCount 件)】"
    $output += "-" * 80
    $longEntries = $Stats.LongestEntries | Select-Object -First $TopCount
    for ($i = 0; $i -lt $longEntries.Count; $i++) {
        $entry = $longEntries[$i]
        $rank = $i + 1
        $status = if (Test-Path $entry) { "✅" } else { "❌" }
        $output += "$(($rank).ToString().PadLeft(2)). [$($entry.Length.ToString().PadLeft(3)) 文字] $status $entry"
    }
    $output += ""
    
    # 重複エントリ
    if ($Stats.Duplicates.Count -gt 0) {
        $output += "【重複エントリ ($($Stats.Duplicates.Count) 個)】"
        $output += "-" * 80
        $Stats.Duplicates | Sort-Object Count -Descending | ForEach-Object {
            $output += "重複 $($_.Count) 回 [$($_.Name.Length) 文字]: $($_.Name)"
        }
        $output += ""
    }
    
    # 存在しないパス
    if ($Stats.NonExistingPaths.Count -gt 0) {
        $output += "【存在しないパス ($($Stats.NonExistingPaths.Count) 個)】"
        $output += "-" * 80
        $Stats.NonExistingPaths | Sort-Object Length -Descending | ForEach-Object {
            $output += "[$($_.Length) 文字] $_"
        }
        $output += ""
    }
    
    # 全エントリリスト（長い順）
    $output += "【全エントリリスト（長い順）】"
    $output += "-" * 80
    for ($i = 0; $i -lt $Stats.LongestEntries.Count; $i++) {
        $entry = $Stats.LongestEntries[$i]
        $rank = $i + 1
        $status = if (Test-Path $entry) { "✅" } else { "❌" }
        $duplicate = if ($Stats.Duplicates | Where-Object { $_.Name -eq $entry }) { " [重複]" } else { "" }
        $output += "$(($rank).ToString().PadLeft(3)). [$($entry.Length.ToString().PadLeft(3)) 文字] $status $entry$duplicate"
    }
    
    return $output
}

function Start-PathAnalysis {
    # 出力ファイル名生成
    if (-not $OutputFile) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $OutputFile = "PATH_Analysis_$timestamp.txt"
    }
    
    Write-Host "=== Windows PATH環境変数分析 ===" -ForegroundColor Green
    Write-Host "作成日時: $(Get-Date -Format 'yyyy年MM月dd日 HH:mm:ss')`n"
    
    $allOutput = @()
    
    # ユーザーPATH分析
    Write-Host "📊 ユーザーPATH環境変数を分析中..." -ForegroundColor Yellow
    try {
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($userPath) {
            $userStats = Get-PathStatistics -PathString $userPath -Type "ユーザー"
            $userAnalysis = Format-PathAnalysis -Stats $userStats -TopCount $ShowTop
            $allOutput += $userAnalysis
            $allOutput += ""
            
            Write-Host "✅ ユーザーPATH: $($userStats.TotalLength) 文字, $($userStats.EntryCount) エントリ" -ForegroundColor Green
        } else {
            Write-Warning "ユーザー環境変数のPATHが取得できませんでした。"
        }
    }
    catch {
        Write-Error "ユーザーPATH取得エラー: $($_.Exception.Message)"
    }
    
    # システムPATH分析（オプション）
    if ($IncludeSystem) {
        Write-Host "📊 システムPATH環境変数を分析中..." -ForegroundColor Yellow
        try {
            $systemPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
            if ($systemPath) {
                $systemStats = Get-PathStatistics -PathString $systemPath -Type "システム"
                $systemAnalysis = Format-PathAnalysis -Stats $systemStats -TopCount $ShowTop
                $allOutput += $systemAnalysis
                $allOutput += ""
                
                Write-Host "✅ システムPATH: $($systemStats.TotalLength) 文字, $($systemStats.EntryCount) エントリ" -ForegroundColor Green
                
                # 合計統計
                $allOutput += "=" * 80
                $allOutput += "【合計統計】"
                $allOutput += "ユーザーPATH: $($userStats.TotalLength) 文字, $($userStats.EntryCount) エントリ"
                $allOutput += "システムPATH: $($systemStats.TotalLength) 文字, $($systemStats.EntryCount) エントリ"
                $allOutput += "合計文字数: $($userStats.TotalLength + $systemStats.TotalLength) 文字"
                $allOutput += "合計エントリ数: $($userStats.EntryCount + $systemStats.EntryCount) エントリ"
                $allOutput += "=" * 80
            } else {
                Write-Warning "システム環境変数のPATHが取得できませんでした。（管理者権限が必要な可能性があります）"
            }
        }
        catch {
            Write-Error "システムPATH取得エラー: $($_.Exception.Message)"
        }
    }
    
    # ファイル出力
    try {
        $allOutput | Out-File -FilePath $OutputFile -Encoding UTF8
        Write-Host "✅ 分析結果を出力しました: $OutputFile" -ForegroundColor Green
        Write-Host "📁 ファイルサイズ: $(((Get-Item $OutputFile).Length / 1KB).ToString('F1')) KB" -ForegroundColor Cyan
        
        # ファイルの先頭部分をプレビュー
        Write-Host "`n📋 出力内容のプレビュー:" -ForegroundColor Cyan
        Write-Host ("-" * 50) -ForegroundColor Gray
        $preview = Get-Content $OutputFile -TotalCount 15
        $preview | ForEach-Object { Write-Host $_ -ForegroundColor White }
        if ((Get-Content $OutputFile).Count -gt 15) {
            Write-Host "... (以下省略)" -ForegroundColor Gray
        }
        Write-Host ("-" * 50) -ForegroundColor Gray
        
    }
    catch {
        Write-Error "ファイル出力エラー: $($_.Exception.Message)"
    }
}

# スクリプト実行
Start-PathAnalysis
