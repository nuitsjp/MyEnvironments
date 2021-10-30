function Install-WingetPackage {
    Write-Host 'Install winget packages.' -ForegroundColor Cyan
    Import-Winget -Path $PSScriptRoot\winget.yml
}

function Update-WingetPackage {
    Write-Host 'Install winget packages.' -ForegroundColor Cyan
    Import-Winget -Path $PSScriptRoot\winget.yml
    Write-Host 'Upgrade winget packages.' -ForegroundColor Cyan
    winget upgrade --all
}
