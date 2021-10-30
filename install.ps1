. $PSScriptRoot\winget\winget.ps1
. $PSScriptRoot\chocolatery\chocolatery.ps1
. $PSScriptRoot\ssms\ssms.ps1

Install-WingetPackage
Install-ChocolateryPackage
Install-SSMS

# PrintInfo -message "Execute install-winget.ps1."
# .\install-winget.ps1

# PrintInfo -message "Execute update.ps1."
# .\update.ps1

# PrintInfo -message "Install SQL Server Management Studio."
# .\install-ssms.ps1
