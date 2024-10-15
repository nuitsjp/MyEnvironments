# Visual Studioの全インストールの構成をエクスポートするスクリプト

# エラーが発生した場合に即座に停止するように設定
$ErrorActionPreference = "Stop"

# Visual Studio Installerのパスを変数として定義
$vsInstallerDir = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer"
$vswhereExe = Join-Path $vsInstallerDir "vswhere.exe"
$vsInstallerExe = Join-Path $vsInstallerDir "vs_installer.exe"

# vswhere.exeの実行結果をJSON形式で取得し、PowerShellオブジェクトに変換
$vsInstallations = & $vswhereExe -format json -prerelease | ConvertFrom-Json

$configDir = Join-Path -Path $PSScriptRoot -ChildPath "vsconfig"
if ((Test-Path -Path $configDir) -eq $false) {
    New-Item -Path $configDir -ItemType Directory > $null
}


foreach ($installation in $vsInstallations) {
    $productId = $installation.productId
    $channelId = $installation.channelId
    $exportPath = Join-Path -Path $configDir -ChildPath "$channelId.vsconfig"

    Write-Host "Exporting configuration for ProductId: $productId ChannelId: $channelId..."

    # 構成のエクスポートを実行（非対話的に）
    $process = Start-Process -FilePath $vsInstallerExe -ArgumentList "export", "--productId", $productId, "--channelId", $channelId, "--config", $exportPath, "--quiet" -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -ne 0) {
        Write-Error "Failed to export configuration for $channelId. Exit code: $($process.ExitCode)"
    }
}

Write-Host "Export process completed." -ForegroundColor Cyan