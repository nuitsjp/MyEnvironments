. $PSScriptRoot\winget\winget.ps1

Import-Module powershell-yaml
Import-Module posh-winget

Write-Host 'Update git repository.' -ForegroundColor Cyan
git pull

Update-WingetPackage
