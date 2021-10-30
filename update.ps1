. $PSScriptRoot\winget\winget.ps1
. $PSScriptRoot\chocolatery\chocolatery.ps1
. $PSScriptRoot\ssms\ssms.ps1

Write-Host 'Update git repository.' -ForegroundColor Cyan
git pull

Update-WingetPackage
Update-ChocolateryPackage
Update-SSMS


# function PrintInfo($message) {
#   Write-Host $message -ForegroundColor Cyan
# }

# PrintInfo -message "Update git repository."
# git pull

# PrintInfo -message "Install/update chocolatey packages."
# .\update-chocolatey.ps1

# PrintInfo -message "Install/update Visual Studio 2019."
# .\update-visualstudio.ps1

