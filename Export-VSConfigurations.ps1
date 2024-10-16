# Visual Studioの全インストールの構成をエクスポートするスクリプト

# エラーが発生した場合に即座に停止するように設定
$ErrorActionPreference = "Stop"

# Visual Studio Installerのパスを変数として定義
$vsInstallerDir = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer"
$vswhereExe = Join-Path $vsInstallerDir "vswhere.exe"
$vsInstallerExe = Join-Path $vsInstallerDir "vs_installer.exe"

# vswhere.exeを使用して、インストールされているすべてのVisual Studioインスタンスの情報を取得
# -prerelease オプションを使用してプレリリースバージョンも含める
$vsInstallations = & $vswhereExe -format json -prerelease | ConvertFrom-Json

# エクスポート先のディレクトリを作成（存在しない場合）
$configDir = Join-Path -Path $PSScriptRoot -ChildPath "vsconfig"
if ((Test-Path -Path $configDir) -eq $false) {
    # 出力を抑制するために > $null を使用
    New-Item -Path $configDir -ItemType Directory | Out-Null
}

# 各Visual Studioインストールに対して構成をエクスポート
foreach ($installation in $vsInstallations) {
    $productId = $installation.productId
    $channelId = $installation.channelId
    $exportPath = Join-Path -Path $configDir -ChildPath "$channelId.vsconfig"

    Write-Host "Exporting configuration for ProductId: $productId ChannelId: $channelId..."

    # Start-Processを使用して構成のエクスポートを実行
    # 重要: Start-Processを使用する理由
    # vs_installer.exeの実行後、スクリプトが自動的に終了せず、Enterキーの入力を待つ問題を解決するため
    $process = Start-Process -FilePath $vsInstallerExe -ArgumentList "export", "--productId", $productId, "--channelId", $channelId, "--config", $exportPath, "--quiet" -NoNewWindow -PassThru -Wait

    # プロセスの終了コードをチェックしてエラーを報告
    if ($process.ExitCode -ne 0) {
        Write-Error "Failed to export configuration for $channelId. Exit code: $($process.ExitCode)"
    }
}

# エクスポートプロセスの完了を通知
Write-Host "Export process completed." -ForegroundColor Cyan