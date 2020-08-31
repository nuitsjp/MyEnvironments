function PrintInfo($message) {
    Write-Host $message -ForegroundColor Cyan
}

gsudo

PrintInfo -message "Execute install-winget.ps1."
install-winget.ps1

PrintInfo -message "Execute update.ps1."
.\update.ps1

PrintInfo -message "Install SQL Server Management Studio."
.\install-ssms.ps1
