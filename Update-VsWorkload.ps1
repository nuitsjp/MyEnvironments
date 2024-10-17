# エラーが発生した場合に即座に停止するように設定
# 管理者権限チェック
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Error "このスクリプトは管理者権限で実行する必要があります。PowerShellを管理者として実行し、スクリプトを再度実行してください。"
    exit 1
}

$ErrorActionPreference = "Stop"

# Visual Studio Installerのパスを変数として定義
$vsInstallerDir = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer"
$vswhereExe = Join-Path $vsInstallerDir "vswhere.exe"
$vsInstallerExe = Join-Path $vsInstallerDir "vs_installer.exe"
$productId = "Microsoft.VisualStudio.Product.Enterprise"
# $productId = "Microsoft.VisualStudio.Product.Professional"
# $productId = "Microsoft.VisualStudio.Product.Community"
# $channelId = "VisualStudio.17.Preview"
$channelId = "VisualStudio.17.Release"
$workloadIds = @(
    "Microsoft.VisualStudio.Workload.CoreEditor",
    "Microsoft.VisualStudio.Workload.NetWeb",
    "Microsoft.VisualStudio.Workload.Azure",
    "Microsoft.VisualStudio.Workload.ManagedDesktop",
    "Microsoft.VisualStudio.Workload.Universal",
    "Microsoft.VisualStudio.Workload.Data",
    "Microsoft.VisualStudio.Workload.DataScience",
    "Microsoft.VisualStudio.Workload.VisualStudioExtension",
    "Microsoft.VisualStudio.Workload.Office",
    "Microsoft.Net.Component.4.8.1.SDK",
    "Microsoft.Net.Component.4.8.1.TargetingPack"
)

# Visual Studioのインストールパスを取得する
$installationPath = & $vswhereExe -format json -prerelease | 
    ConvertFrom-Json | 
    Where-Object { $_.productId -eq $productId -and $_.channelId -eq $channelId } | 
    Select-Object -First 1 | 
    Select-Object -ExpandProperty installationPath

foreach ($workloadId in $workloadIds) {
    $isExists = & $vswhereExe `
        -products $productId `
        -requires $workloadId `
        -format json `
        -prerelease | 
        ConvertFrom-Json | 
        Where-Object { $_.channelId -eq $channelId } |
        Measure-Object | 
        ForEach-Object { $_.Count -gt 0 }

    if ($isExists -eq $false) {
        Write-Host "Workload '$workloadId' is not installed. Adding workload..." -ForegroundColor Cyan
        # Start-Processを使用してワークロードやコンポーネントを追加
        # 重要: Start-Processを使用する理由
        # vs_installer.exeの実行後、スクリプトが自動的に終了せず、Enterキーの入力を待つ問題を解決するため
        $process = Start-Process `
            -FilePath $vsInstallerExe `
            -ArgumentList `
                "modify", `
                "--productId", $productId, `
                "--channelId", $channelId, `
                "--add", $workloadId, `
                "--includeRecommended", `
                "--quiet", `
                "--norestart" `
            -NoNewWindow `
            -PassThru `
            -Wait

        # プロセスの終了コードをチェックしてエラーを報告
        if ($process.ExitCode -ne 0) {
            Write-Error "チャンネル $channelId のインストール修正に失敗しました。終了コード: $($process.ExitCode)"
        }
        else {
            Write-Host "Workload '$workloadId' のインストール修正に成功しました。" -ForegroundColor Cyan
        }
    }
    else {
        Write-Host "Workload '$workloadId' は既にインストールされています。"
    }
}
