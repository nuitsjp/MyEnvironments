<#
.SYNOPSIS
    システムPATHとユーザーPATHの重複エントリを削除するスクリプト

.DESCRIPTION
    ユーザー環境変数のPATHからシステム環境変数のPATHに既に含まれている
    重複エントリを除去して、PATH環境変数を最適化します。

.PARAMETER WhatIf
    実際に変更を適用せず、変更内容のみを表示します（推奨）

.PARAMETER Force
    確認なしで変更を適用します（注意して使用）

.PARAMETER CreateBackup
    変更前にバックアップファイルを作成します（デフォルト: true）

.EXAMPLE
    .\Remove-DuplicatePaths.ps1 -WhatIf
    重複削除の変更内容をプレビューします（推奨）

.EXAMPLE
    .\Remove-DuplicatePaths.ps1
    対話形式で重複エントリを削除

.EXAMPLE
    .\Remove-DuplicatePaths.ps1 -Force
    確認なしで重複エントリを削除
#>

[CmdletBinding()]
param(
    [switch]$WhatIf,
    [switch]$Force,
    [bool]$CreateBackup = $true
)

# バックアップ作成関数
function New-PathBackup {
    param(
        [string]$Path,
        [string]$Type = "User"
    )
    
    if (-not $CreateBackup) {
        return $null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "PATH_Backup_${Type}_Duplicate_Cleanup_$timestamp.txt"
    
    $Path | Out-File -FilePath $backupFile -Encoding UTF8
    Write-Host "✅ ${Type}PATHのバックアップを作成しました: $backupFile" -ForegroundColor Green
    return $backupFile
}

# パス正規化関数
function Format-PathString {
    param([string]$Path)
    
    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ""
    }
    
    # 末尾のバックスラッシュを除去して統一
    return $Path.TrimEnd('\').Trim()
}

# 重複分析関数
function Find-PathDuplicates {
    Write-Host "=== PATH重複分析開始 ===" -ForegroundColor Cyan
    
    # システムPATHとユーザーPATHを取得
    try {
        $systemPathString = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        $userPathString = [Environment]::GetEnvironmentVariable("PATH", "User")
        
        if ([string]::IsNullOrEmpty($systemPathString)) {
            Write-Warning "システムPATHが取得できません。"
            return $null
        }
        
        if ([string]::IsNullOrEmpty($userPathString)) {
            Write-Warning "ユーザーPATHが取得できません。"
            return $null
        }
    }
    catch {
        Write-Error "PATH環境変数の取得に失敗しました: $($_.Exception.Message)"
        return $null
    }
    
    # パスエントリに分割
    $systemPaths = $systemPathString -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $userPaths = $userPathString -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    
    # 正規化されたパスで比較用ハッシュテーブル作成
    $systemPathsNormalized = @{}
    foreach ($path in $systemPaths) {
        $normalizedPath = Format-PathString -Path $path
        if ($normalizedPath) {
            $systemPathsNormalized[$normalizedPath] = $path
        }
    }
    
    # 重複と非重複を分類
    $duplicatePaths = @()
    $uniquePaths = @()
    
    foreach ($userPath in $userPaths) {
        $normalizedUserPath = Format-PathString -Path $userPath
        
        if ($normalizedUserPath -and $systemPathsNormalized.ContainsKey($normalizedUserPath)) {
            $duplicatePaths += $userPath
        } else {
            $uniquePaths += $userPath
        }
    }
    
    # 結果表示
    Write-Host "`n=== 分析結果 ===" -ForegroundColor Yellow
    Write-Host "システムPATH エントリ数: $($systemPaths.Count)"
    Write-Host "ユーザーPATH エントリ数: $($userPaths.Count)"
    Write-Host "重複エントリ数: $($duplicatePaths.Count)"
    Write-Host "ユニークエントリ数: $($uniquePaths.Count)"
    Write-Host "重複率: $(($duplicatePaths.Count / $userPaths.Count * 100).ToString('F1'))%"
    
    if ($duplicatePaths.Count -gt 0) {
        Write-Host "`n🔄 検出された重複エントリ:" -ForegroundColor Red
        for ($i = 0; $i -lt $duplicatePaths.Count; $i++) {
            Write-Host "  $($i + 1). $($duplicatePaths[$i])"
        }
    }
    
    if ($uniquePaths.Count -gt 0) {
        Write-Host "`n✨ 残される ユニークエントリ:" -ForegroundColor Green
        for ($i = 0; $i -lt $uniquePaths.Count; $i++) {
            Write-Host "  $($i + 1). $($uniquePaths[$i])"
        }
    }
    
    # 削減効果計算
    $originalLength = $userPathString.Length
    $cleanedPath = ($uniquePaths | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join ';'
    $newLength = $cleanedPath.Length
    $savedChars = $originalLength - $newLength
    
    Write-Host "`n=== 削減効果 ===" -ForegroundColor Cyan
    Write-Host "削減エントリ数: $($duplicatePaths.Count) 個"
    Write-Host "削減文字数: $savedChars 文字"
    Write-Host "変更前文字数: $originalLength 文字"
    Write-Host "変更後文字数: $newLength 文字"
    Write-Host "制限(2047文字)との差: $(if($newLength -gt 2047){"❌ +$($newLength - 2047) 文字オーバー"}else{"✅ -$(2047 - $newLength) 文字余裕"})"
    
    return @{
        SystemPaths = $systemPaths
        UserPaths = $userPaths
        DuplicatePaths = $duplicatePaths
        UniquePaths = $uniquePaths
        OriginalUserPath = $userPathString
        CleanedPath = $cleanedPath
        SavedChars = $savedChars
        SavedEntries = $duplicatePaths.Count
    }
}

# 重複削除実行関数
function Remove-PathDuplicates {
    param(
        [hashtable]$AnalysisResult,
        [bool]$WhatIfMode,
        [bool]$ForceMode
    )
    
    if ($AnalysisResult.SavedEntries -eq 0) {
        Write-Host "`n✅ 重複エントリが見つかりませんでした。処理の必要はありません。" -ForegroundColor Green
        return $true
    }
    
    Write-Host "`n=== 重複削除処理 ===" -ForegroundColor Yellow
    
    # WhatIfモードの場合は結果のみ表示
    if ($WhatIfMode) {
        Write-Host "💡 WhatIfモード: 実際の変更は行いません" -ForegroundColor Yellow
        Write-Host "`n変更後のユーザーPATH (プレビュー):" -ForegroundColor Magenta
        $AnalysisResult.UniquePaths | ForEach-Object { 
            if (-not [string]::IsNullOrWhiteSpace($_)) {
                Write-Host "  $_"
            }
        }
        return $true
    }
    
    # 確認プロンプト（-Force指定時はスキップ）
    if (-not $ForceMode) {
        Write-Host "`n⚠️  $($AnalysisResult.SavedEntries)個の重複エントリをユーザーPATHから削除しますか？" -ForegroundColor Yellow
        Write-Host "   削減文字数: $($AnalysisResult.SavedChars) 文字"
        Write-Host "   バックアップは自動で作成されます。"
        $response = Read-Host "続行しますか？ (Y/N)"
        if ($response -notmatch '^[Yy]') {
            Write-Host "重複削除処理を中止しました。" -ForegroundColor Yellow
            return $true
        }
    }
    
    # バックアップ作成
    $backupFile = New-PathBackup -Path $AnalysisResult.OriginalUserPath -Type "User"
    
    # ユーザーPATH更新実行
    try {
        [Environment]::SetEnvironmentVariable("PATH", $AnalysisResult.CleanedPath, "User")
        Write-Host "✅ ユーザーPATHから重複エントリを削除しました！" -ForegroundColor Green
        
        # 結果確認
        $newUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        Write-Host "`n=== 削除完了 ===" -ForegroundColor Green
        Write-Host "削除前: $($AnalysisResult.OriginalUserPath.Length) 文字 ($($AnalysisResult.UserPaths.Count) エントリ)"
        Write-Host "削除後: $($newUserPath.Length) 文字 ($($AnalysisResult.UniquePaths.Count) エントリ)"
        Write-Host "削減量: $($AnalysisResult.SavedChars) 文字 ($($AnalysisResult.SavedEntries) エントリ)"
        
        Write-Host "`n📝 注意事項:" -ForegroundColor Yellow
        Write-Host "- 新しいコマンドプロンプト/PowerShellを開いて変更を確認してください"
        Write-Host "- すべてのアプリケーションが正常に動作することを確認してください"
        if ($backupFile) {
            Write-Host "- 問題がある場合は、バックアップファイルから復元できます: $backupFile"
            Write-Host "- 復元コマンド: [Environment]::SetEnvironmentVariable('PATH', (Get-Content '$backupFile'), 'User')"
        }
        
        return $true
    }
    catch {
        Write-Error "ユーザーPATH更新に失敗しました: $($_.Exception.Message)"
        if ($backupFile) {
            Write-Host "バックアップファイル: $backupFile" -ForegroundColor Yellow
        }
        return $false
    }
}

# メイン処理関数
function Start-DuplicateRemoval {
    Write-Host "=== PATH重複エントリ削除スクリプト ===" -ForegroundColor Green
    Write-Host "実行日時: $(Get-Date -Format 'yyyy年MM月dd日 HH:mm:ss')"
    Write-Host "目的: ユーザーPATHからシステムPATHとの重複エントリを削除" -ForegroundColor Cyan
    
    # 重複分析実行
    $analysisResult = Find-PathDuplicates
    if (-not $analysisResult) {
        Write-Error "PATH分析に失敗しました。"
        return
    }
    
    # 重複削除処理
    $success = Remove-PathDuplicates -AnalysisResult $analysisResult -WhatIfMode $WhatIf -ForceMode $Force
    
    # 最終メッセージ
    Write-Host "`n" + ("=" * 70) -ForegroundColor Green
    if ($WhatIf) {
        Write-Host "💡 実際に適用するには -WhatIf を外して再実行してください。" -ForegroundColor Yellow
        Write-Host "   例: .\Remove-DuplicatePaths.ps1" -ForegroundColor Yellow
    } else {
        if ($success) {
            Write-Host "✅ PATH重複エントリの削除が完了しました！" -ForegroundColor Green
            Write-Host "新しいターミナルを開いて変更を確認してください。" -ForegroundColor Yellow
        } else {
            Write-Host "⚠️ 処理中に問題が発生しました。" -ForegroundColor Yellow
        }
    }
    Write-Host ("=" * 70) -ForegroundColor Green
}

# スクリプト実行
Start-DuplicateRemoval
