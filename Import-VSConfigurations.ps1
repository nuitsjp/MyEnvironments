# Visual Studioの構成をインポートし、必要な場合のみインストールを修正するスクリプト

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

    Write-Host "製品ID: $productId、チャンネルID: $channelId の現在の設定を確認しています..."

    # 一時ファイルを作成
    $tempFile = New-TemporaryFile

    try {
        # 現在の設定をエクスポート（出力を抑制）
        # この方法を使用する理由：
        # 1. インストーラーから出力される大量のログを抑制するため
        # 2. 設定の確認中であることを明確にし、更新中との混同を避けるため
        # 3. スクリプトの出力をクリーンに保ち、重要な情報を見やすくするため
        $exportCommand = "& '$vsInstallerExe' export --productId $productId --channelId $channelId --config '$($tempFile.FullName)' --quiet; exit `$LASTEXITCODE"
        $encodedExportCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($exportCommand))
        $exportProcess = Start-Process pwsh.exe -ArgumentList "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-EncodedCommand", $encodedExportCommand -WindowStyle Hidden -PassThru -Wait
        $exportExitCode = $exportProcess.ExitCode

        if ($exportExitCode -ne 0) {
            Write-Error "チャンネル $channelId の現在の設定のエクスポートに失敗しました。終了コード: $exportExitCode"
            continue
        }

        # 設定ファイルの内容を比較
        $currentConfig = Get-Content -Path $tempFile.FullName -Raw
        $newConfig = Get-Content -Path $vsconfigPath -Raw

        if ($currentConfig -eq $newConfig) {
            Write-Host "チャンネル $channelId の設定に変更はありません。スキップします。"
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
        }
    }
    finally {
        # 一時ファイルを削除
        Remove-Item -Path $tempFile.FullName -Force
    }
}

Write-Host "修正プロセスが完了しました。" -ForegroundColor Cyan