# エラーが発生した場合に即座に停止するように設定
$ErrorActionPreference = "Stop"

# 管理者権限チェック
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "このスクリプトは管理者権限で実行する必要があります。PowerShellを管理者として実行し、スクリプトを再度実行してください。"
    exit 1
}

# Visual Studio Installerのパスを変数として定義
$vsInstallerDir = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer"
$vswhereExe = Join-Path $vsInstallerDir "vswhere.exe"
$vsInstallerExe = Join-Path $vsInstallerDir "vs_installer.exe"
$productIds = @(
    "Microsoft.VisualStudio.Product.Enterprise",
    "Microsoft.VisualStudio.Product.Professional",
    "Microsoft.VisualStudio.Product.Community"
)
$channelIds = @(
    "VisualStudio.17.Preview",
    "VisualStudio.17.Release"
)
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

# プロダクトとチャネルの組み合わせを作成
$combinations = foreach ($productId in $productIds) {
    foreach ($channelId in $channelIds) {
        [PSCustomObject]@{
            ProductId = $productId
            ChannelId = $channelId
        }
    }
}

# インストールパスを取得し、インストール可能なプロダクトとチャネルを特定
$missingWorkloads = @()
foreach ($combination in $combinations) {
    $productId = $combination.ProductId
    $channelId = $combination.ChannelId

    $installationPath = & $vswhereExe -format json -prerelease |
        ConvertFrom-Json |
        Where-Object { $_.productId -eq $productId -and $_.channelId -eq $channelId } |
        Select-Object -First 1 |
        Select-Object -ExpandProperty installationPath -ErrorAction SilentlyContinue

    if ($installationPath) {
        # インストールされていないワークロードをチェック
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
                Write-Host "Workload '$workloadId' is not installed." -ForegroundColor Yellow
                $missingWorkloads += $workloadId
            }
            else {
                Write-Host "Workload '$workloadId' は既にインストールされています。"
            }
        }

        # 未インストールのワークロードがあれば一括でインストール
        if ($missingWorkloads.Count -gt 0) {
            Write-Host "以下のワークロードをインストールします: $($missingWorkloads -join ', ')" -ForegroundColor Cyan

            # Start-Processを使用してワークロードを一括で追加
            # 重要: Start-Processを使用する理由
            # vs_installer.exeの実行後、スクリプトが自動的に終了せず、Enterキーの入力を待つ問題を解決するため
            $process = Start-Process `
                -FilePath $vsInstallerExe `
                -ArgumentList `
                    "modify", `
                    "--productId", $productId, `
                    "--channelId", $channelId, `
                    "--add", ($missingWorkloads -join " --add "), `
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
                Write-Host "ワークロードのインストール修正に成功しました。" -ForegroundColor Cyan
            }
        }
        else {
            Write-Host "すべてのワークロードは既にインストールされています。"
        }
    }
}