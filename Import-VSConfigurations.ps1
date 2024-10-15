# Visual Studioの構成をインポートし、インストールを修正するスクリプト

# 管理者権限チェック
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Error "このスクリプトは管理者権限で実行する必要があります。PowerShellを管理者として実行し、スクリプトを再度実行してください。"
    exit 1
}

# エラーが発生した場合に即座に停止するように設定
$ErrorActionPreference = "Stop"

# Visual Studio Installerのパスを変数として定義
$vsInstallerDir = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer"
$vswhereExe = Join-Path $vsInstallerDir "vswhere.exe"
$vsInstallerExe = Join-Path $vsInstallerDir "vs_installer.exe"

# vswhere.exeを使用して、インストールされているすべてのVisual Studioインスタンスの情報を取得
# -prerelease オプションを使用してプレリリースバージョンも含める
$vsInstallations = & $vswhereExe -format json -prerelease | ConvertFrom-Json

# 設定ファイルが保存されているディレクトリを指定
$configDir = Join-Path -Path $PSScriptRoot -ChildPath "vsconfig"

# 設定ディレクトリが存在することを確認
if (-not (Test-Path $configDir)) {
    Write-Error "設定ディレクトリが見つかりません: $configDir"
    exit 1
}

foreach ($installation in $vsInstallations) {
    $productId = $installation.productId
    $channelId = $installation.channelId
    $vsconfigPath = Join-Path -Path $configDir -ChildPath "$channelId.vsconfig"

    # 該当するチャンネルの設定ファイルが存在するか確認
    if (-not (Test-Path $vsconfigPath)) {
        Write-Host "チャンネル $channelId の設定ファイルが見つかりません。このインストールはスキップします。"
        continue
    }

    Write-Host "製品ID: $productId、チャンネルID: $channelId のインストールを修正しています..."

    # Start-Processを使用してインストールの修正を実行
    # 重要: Start-Processを使用する理由
    # vs_installer.exeの実行後、スクリプトが自動的に終了せず、Enterキーの入力を待つ問題を解決するため
    $process = Start-Process -FilePath $vsInstallerExe -ArgumentList "modify", "--productId", $productId, "--channelId", $channelId, "--config", $vsconfigPath, "--quiet", "--norestart" -NoNewWindow -PassThru -Wait

    # プロセスの終了コードをチェックしてエラーを報告
    if ($process.ExitCode -ne 0) {
        Write-Error "チャンネル $channelId のインストール修正に失敗しました。終了コード: $($process.ExitCode)"
    } else {
        Write-Host "チャンネル $channelId のインストール修正が成功しました。"
    }

    Write-Host "---"
}

Write-Host "修正プロセスが完了しました。" -ForegroundColor Cyan