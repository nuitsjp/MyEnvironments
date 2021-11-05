. $PSScriptRoot\winget\winget.ps1
. $PSScriptRoot\chocolatery\chocolatery.ps1
. $PSScriptRoot\visualstudio\visualstudio.ps1

Import-Module powershell-yaml
Import-Module posh-winget

Write-Host 'Update git repository.' -ForegroundColor Cyan
git pull

Update-VisualStudio2019
Update-WingetPackage
Update-ChocolateryPackage
