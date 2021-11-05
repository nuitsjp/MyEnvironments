. $PSScriptRoot\winget\winget.ps1
. $PSScriptRoot\chocolatery\chocolatery.ps1
. $PSScriptRoot\visualstudio\visualstudio.ps1

Import-Module powershell-yaml
Import-Module posh-winget

Install-VisualStudio2019
Install-WingetPackage
Install-ChocolateryPackage
