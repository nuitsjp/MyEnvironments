<#
.SYNOPSIS
    Windows PATH環境変数のクリーンアップスクリプト

.DESCRIPTION
    ユーザー環境変数のPATHから重複パス、存在しないパス、不要なパスを除去して
    Windows環境変数の制限（2047文字）内に収めるスクリプトです。

.PARAMETER WhatIf
    実際に変更を適用せず、変更内容のみを表示します（推奨）

.PARAMETER Force
    確認なしで変更を適用します（注意して使用）

.PARAMETER IncludeSystem
    システム環境変数のPATHも清掃対象に含めます（管理者権限必要）

.PARAMETER SystemOnly
    システム環境変数のPATHのみを清掃します（管理者権限必要）

.EXAMPLE
    .\Cleanup-PathEnvironment.ps1 -WhatIf
    ユーザーPATHの変更内容をプレビューします（推奨）

.EXAMPLE
    .\Cleanup-PathEnvironment.ps1 -IncludeSystem -WhatIf
    ユーザーとシステム両方のPATHをプレビューします

.EXAMPLE
    .\Cleanup-PathEnvironment.ps1 -SystemOnly -WhatIf
    システムPATHのみをプレビューします

.EXAMPLE
    .\Cleanup-PathEnvironment.ps1 -IncludeSystem
    ユーザーとシステム両方のPATHを対話形式で清掃

.EXAMPLE
    .\Cleanup-PathEnvironment.ps1 -Force
    ユーザーPATHを確認なしで清掃
#>

[CmdletBinding()]
param(
    [switch]$WhatIf,
    [switch]$Force,
    [switch]$IncludeSystem,
    [switch]$SystemOnly
)

# 管理者権限チェック
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# バックアップ作成
function Create-PathBackup {
    param(
        [string]$Path,
        [string]$Type = "User"
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "PATH_Backup_${Type}_$timestamp.txt"
    
    $Path | Out-File -FilePath $backupFile -Encoding UTF8
    Write-Host "✅ ${Type}PATHのバックアップを作成しました: $backupFile" -ForegroundColor Green
    return $backupFile
}

# パス正規化（末尾のバックスラッシュを統一）
function Normalize-Path {
    param([string]$Path)
    
    if ($Path -and $Path -ne "" -and $Path -ne "C") {
        # 末尾のバックスラッシュを除去して統一
        return $Path.TrimEnd('\')
    }
    return $Path
}

# 類似パス検出（バックスラッシュ有無による重複を検出）
function Find-SimilarPaths {
    param([array]$Entries)
    
    $similarGroups = @{}
    $processedPaths = @()
    
    foreach ($entry in $Entries) {
        $normalizedPath = Normalize-Path -Path $entry
        if ($normalizedPath -and $normalizedPath -ne "") {
            if (-not $similarGroups.ContainsKey($normalizedPath)) {
                $similarGroups[$normalizedPath] = @()
            }
            $similarGroups[$normalizedPath] += $entry
        }
    }
    
    # 複数のバリエーションがあるパスのみを返す
    $similar = $similarGroups.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
    return $similar
}

# パス分析
function Analyze-Path {
    param(
        [string]$PathString,
        [string]$Type = "User"
    )
    
    $entries = $PathString -split ';' | Where-Object { $_ -ne "" }
    $duplicates = $entries | Group-Object | Where-Object { $_.Count -gt 1 }
    $similarPaths = Find-SimilarPaths -Entries $entries
    $nonExistent = @()
    $valid = @()
    
    Write-Host "`n=== ${Type} PATH分析結果 ===" -ForegroundColor Cyan
    Write-Host "総エントリ数: $($entries.Count)"
    Write-Host "総文字数: $($PathString.Length) 文字"
    Write-Host "制限(2047文字)との差: $(if($PathString.Length -gt 2047){"❌ +$($PathString.Length - 2047) 文字オーバー"}else{"✅ -$(2047 - $PathString.Length) 文字余裕"})"
    
    # 完全重複パス確認
    if ($duplicates.Count -gt 0) {
        Write-Host "`n🔄 完全重複パス ($($duplicates.Count)個):" -ForegroundColor Yellow
        $duplicates | ForEach-Object { Write-Host "  [$($_.Count)回] $($_.Name)" }
    }
    
    # 類似パス確認（バックスラッシュ有無による類似）
    if ($similarPaths.Count -gt 0) {
        Write-Host "`n🔗 類似パス ($($similarPaths.Count)グループ):" -ForegroundColor Magenta
        $similarPaths | ForEach-Object {
            Write-Host "  グループ [$($_.Key)]:"
            $_.Value | ForEach-Object { Write-Host "    - $_" }
        }
    }
    
    # 存在確認
    Write-Host "`n📁 パス存在確認中..." -ForegroundColor Yellow
    foreach ($entry in $entries) {
        if ($entry -and $entry -ne "" -and $entry -ne "C") {
            if (Test-Path $entry) {
                $valid += $entry
            } else {
                $nonExistent += $entry
            }
        } elseif ($entry -eq "C") {
            $nonExistent += $entry  # "C"単体は無効
        }
    }
    
    if ($nonExistent.Count -gt 0) {
        Write-Host "`n❌ 存在しないパス ($($nonExistent.Count)個):" -ForegroundColor Red
        $nonExistent | ForEach-Object { Write-Host "  $_" }
    }
    
    return @{
        Type = $Type
        Original = $entries
        Duplicates = $duplicates
        SimilarPaths = $similarPaths
        NonExistent = $nonExistent
        Valid = $valid
        UniqueValidNormalized = ($valid | ForEach-Object { Normalize-Path $_ } | Sort-Object -Unique | Where-Object { $_ -ne "" })
    }
}

# PATH処理（ユーザーまたはシステム）
function Process-PathType {
    param(
        [string]$PathType,
        [bool]$WhatIfMode,
        [bool]$ForceMode
    )
    
    $envTarget = if ($PathType -eq "System") { "Machine" } else { "User" }
    $displayName = if ($PathType -eq "System") { "システム" } else { "ユーザー" }
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Blue
    Write-Host "${displayName}環境変数のPATH処理を開始します" -ForegroundColor Blue
    Write-Host ("=" * 60) -ForegroundColor Blue
    
    # 管理者権限チェック（システムPATHの場合）
    if ($PathType -eq "System" -and -not (Test-IsAdmin)) {
        Write-Error "システム環境変数の変更には管理者権限が必要です。"
        Write-Host "PowerShellを管理者として実行してください。" -ForegroundColor Yellow
        return $false
    }
    
    # 現在のPATH取得
    try {
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", $envTarget)
        if (-not $currentPath) {
            Write-Warning "${displayName}環境変数のPATHが取得できません。"
            return $false
        }
    }
    catch {
        Write-Error "${displayName}環境変数の取得に失敗しました: $($_.Exception.Message)"
        return $false
    }
    
    # 分析実行
    $analysis = Analyze-Path -PathString $currentPath -Type $displayName
    
    # 清掃結果計算
    $cleanPath = $analysis.UniqueValidNormalized -join ';'
    $savedChars = $currentPath.Length - $cleanPath.Length
    $savedEntries = $analysis.Original.Count - $analysis.UniqueValidNormalized.Count
    $duplicateReduction = $analysis.Duplicates.Count
    $similarReduction = ($analysis.SimilarPaths | Measure-Object -Property { $_.Value.Count - 1 } -Sum).Sum
    
    Write-Host "`n=== ${displayName}清掃結果予測 ===" -ForegroundColor Cyan
    Write-Host "削減エントリ数: $savedEntries 個"
    Write-Host "  - 完全重複: $duplicateReduction 個"
    Write-Host "  - 類似パス: $similarReduction 個"
    Write-Host "  - 存在しないパス: $($analysis.NonExistent.Count) 個"
    Write-Host "削減文字数: $savedChars 文字"
    Write-Host "清掃後文字数: $($cleanPath.Length) 文字"
    
    if ($cleanPath.Length -le 2047) {
        Write-Host "✅ 制限内に収まります！ (余裕: $(2047 - $cleanPath.Length)文字)" -ForegroundColor Green
    } else {
        Write-Host "❌ まだ制限を超えています (超過: $($cleanPath.Length - 2047)文字)" -ForegroundColor Red
        Write-Host "   追加の手動削除が必要です。" -ForegroundColor Yellow
    }
    
    # WhatIfモードの場合は結果のみ表示
    if ($WhatIfMode) {
        Write-Host "`n=== ${displayName}清掃後のPATH (プレビュー) ===" -ForegroundColor Magenta
        $analysis.UniqueValidNormalized | ForEach-Object { Write-Host "  $_" }
        return $true
    }
    
    # 確認プロンプト（-Force指定時はスキップ）
    if (-not $ForceMode) {
        Write-Host "`n⚠️  ${displayName}環境変数のこの変更を適用しますか？" -ForegroundColor Yellow
        if ($PathType -eq "System") {
            Write-Host "   ⚠️ システム環境変数の変更は全ユーザーに影響します！" -ForegroundColor Red
        }
        Write-Host "   バックアップは自動で作成されます。"
        $response = Read-Host "続行しますか？ (Y/N)"
        if ($response -notmatch '^[Yy]') {
            Write-Host "${displayName}PATH処理を中止しました。" -ForegroundColor Yellow
            return $true
        }
    }
    
    # バックアップ作成
    $backupFile = Create-PathBackup -Path $currentPath -Type $PathType
    
    # PATH更新実行
    try {
        [Environment]::SetEnvironmentVariable("PATH", $cleanPath, $envTarget)
        Write-Host "✅ ${displayName}環境変数のPATHを更新しました！" -ForegroundColor Green
        
        # 結果確認
        $newPath = [Environment]::GetEnvironmentVariable("PATH", $envTarget)
        Write-Host "`n=== ${displayName}更新完了 ===" -ForegroundColor Green
        Write-Host "更新前: $($currentPath.Length) 文字 ($($analysis.Original.Count) エントリ)"
        Write-Host "更新後: $($newPath.Length) 文字 ($($analysis.UniqueValidNormalized.Count) エントリ)"
        Write-Host "削減量: $($currentPath.Length - $newPath.Length) 文字 ($($analysis.Original.Count - $analysis.UniqueValidNormalized.Count) エントリ)"
        
        Write-Host "`n📝 ${displayName}PATH注意事項:" -ForegroundColor Yellow
        if ($PathType -eq "System") {
            Write-Host "- システム再起動またはログオフ・ログオンで変更が全ユーザーに反映されます"
        } else {
            Write-Host "- 新しいコマンドプロンプト/PowerShellを開いて変更を確認してください"
        }
        Write-Host "- 問題がある場合は、バックアップファイルから復元できます: $backupFile"
        Write-Host "- 復元コマンド: [Environment]::SetEnvironmentVariable('PATH', (Get-Content '$backupFile'), '$envTarget')"
        
        return $true
    }
    catch {
        Write-Error "${displayName}PATH更新に失敗しました: $($_.Exception.Message)"
        Write-Host "バックアップファイル: $backupFile" -ForegroundColor Yellow
        return $false
    }
}

# メイン処理
function Start-PathCleanup {
    Write-Host "=== Windows PATH環境変数クリーンアップ ===" -ForegroundColor Green
    Write-Host "作成日時: $(Get-Date -Format 'yyyy年MM月dd日 HH:mm:ss')"
    
    # パラメータ検証
    if ($SystemOnly -and $IncludeSystem) {
        Write-Error "-SystemOnly と -IncludeSystem は同時に指定できません。"
        return
    }
    
    # 処理対象の決定
    $processUser = -not $SystemOnly
    $processSystem = $IncludeSystem -or $SystemOnly
    
    Write-Host "`n📋 処理対象:" -ForegroundColor Cyan
    if ($processUser) { Write-Host "  ✅ ユーザー環境変数のPATH" }
    if ($processSystem) { Write-Host "  ✅ システム環境変数のPATH" }
    
    if ($WhatIf) {
        Write-Host "`n💡 WhatIfモード: 実際の変更は行いません" -ForegroundColor Yellow
    }
    
    $overallSuccess = $true
    
    # ユーザーPATH処理
    if ($processUser) {
        $success = Process-PathType -PathType "User" -WhatIfMode $WhatIf -ForceMode $Force
        $overallSuccess = $overallSuccess -and $success
    }
    
    # システムPATH処理
    if ($processSystem) {
        $success = Process-PathType -PathType "System" -WhatIfMode $WhatIf -ForceMode $Force
        $overallSuccess = $overallSuccess -and $success
    }
    
    # 最終メッセージ
    Write-Host "`n" + ("=" * 60) -ForegroundColor Green
    if ($WhatIf) {
        Write-Host "💡 実際に適用するには -WhatIf を外して再実行してください。" -ForegroundColor Yellow
    } else {
        if ($overallSuccess) {
            Write-Host "✅ PATH環境変数の清掃が完了しました！" -ForegroundColor Green
        } else {
            Write-Host "⚠️ 一部の処理で問題が発生しました。" -ForegroundColor Yellow
        }
    }
    Write-Host ("=" * 60) -ForegroundColor Green
}

# スクリプト実行
Start-PathCleanup
