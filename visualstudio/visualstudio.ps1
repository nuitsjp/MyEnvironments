function Install-VisualStudio2019 {
    $displayName = 'Visual Studio Enterprise 2019'
    $installed = Invoke-WingetList -Id Microsoft.VisualStudio.2019.Enterprise
    if ($installed.Length -ne 0) {
        Write-Host "$displayName is already installed." -ForegroundColor Cyan
        return
    }

    Write-Host "Install $displayName" -ForegroundColor Cyan
    Use-TempDir {
        Invoke-WebRequest -UseBasicParsing -Uri http://aka.ms/vs/16/release/vs_enterprise.exe -OutFile vs_enterprise.exe
        Start-Process -FilePath vs_enterprise.exe -ArgumentList "--config `"${PSScriptRoot}\.vs2019enterprise_config`" --passive --norestart --wait" -Verb runas -Wait
        Write-Host "$displayName is installed." -ForegroundColor Cyan
    }
}

function Update-VisualStudio2019 {
    $displayName = 'Visual Studio Enterprise 2019'
    $installed = Invoke-WingetList -Id Microsoft.VisualStudio.2019.Enterprise
    if ($installed.Length -eq 0) {
        Write-Host "$displayName is not installed." -ForegroundColor Cyan
        return
    }

    if ($null -eq $installed.Available) {
        Write-Host "$displayName is already up to date." -ForegroundColor Cyan
        return
    }

    Write-Host "Update $displayName" -ForegroundColor Cyan
    Use-TempDir {
        Invoke-WebRequest -UseBasicParsing -Uri http://aka.ms/vs/16/release/vs_enterprise.exe -OutFile vs_enterprise.exe
        Start-Process -FilePath vs_enterprise.exe -ArgumentList "update --passive --norestart --wait" -Verb runas -Wait
        Write-Host "$displayName has been updated." -ForegroundColor Cyan
    }
}

function Get-InstalledApplication {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $DisplayName
    )

    Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
        Where-Object { $_.DisplayName -eq $DisplayName}
}

function Use-TempDir {
    param (
        [ScriptBlock]$Script
    )
    $tmp = $env:TEMP | Join-Path -ChildPath $([System.Guid]::NewGuid().Guid)
    New-Item -ItemType Directory -Path $tmp | Push-Location
    try {
        Invoke-Command -ScriptBlock $script
    }
    finally {
        Pop-Location
        $tmp | Remove-Item -Recurse
    }
}