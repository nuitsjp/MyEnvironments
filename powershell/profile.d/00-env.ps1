function Sync-UserEnvironments {
    # 同期元ディレクトリ
    $sourceDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\windows\home"))
    # VS Code 設定の同期元ディレクトリ
    $codeSourceDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\windows\code"))
    # 同期先のユーザープロファイル
    $destDir = $env:USERPROFILE

    # 同期元が存在しない場合は中断
    if (-not (Test-Path $sourceDir)) {
        Write-Warning "Source directory not found: $sourceDir"
        return
    }

    # ユーザープロファイルへコピー（キャッシュは除外）
    Copy-Item -Path "$sourceDir\*" -Destination $destDir -Recurse -Force -Exclude "stats-cache.json"
    Write-Host "Synced files from $sourceDir to $destDir"

    # VS Code 設定の同期元が存在しない場合は中断
    if (-not (Test-Path $codeSourceDir)) {
        Write-Warning "Source directory not found: $codeSourceDir"
        return
    }

    # VS Code / VS Code Insiders の設定先
    $codeDestDirs = @(
        (Join-Path $env:USERPROFILE "AppData\Roaming\Code\User"),
        (Join-Path $env:USERPROFILE "AppData\Roaming\Code - Insiders\User")
    )

    foreach ($codeDestDir in $codeDestDirs) {
        # 設定先を作成してから上書きコピー
        New-Item -Path $codeDestDir -ItemType Directory -Force | Out-Null
        Copy-Item -Path "$codeSourceDir\*" -Destination $codeDestDir -Recurse -Force
        Write-Host "Synced files from $codeSourceDir to $codeDestDir"
    }
}

Set-Alias -Name sync-home -Value Sync-UserEnvironments
