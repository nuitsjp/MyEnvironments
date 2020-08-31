function PrintInfo($message) {
    Write-Host $message -ForegroundColor Cyan
}

.\update.ps1

PrintInfo -message "Install SQL Server Management Studio."
.\install-ssms.ps1
