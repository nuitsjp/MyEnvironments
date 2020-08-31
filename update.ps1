function PrintInfo($message) {
  Write-Host $message -ForegroundColor Cyan
}

gsudo

PrintInfo -message "Update git repository."
git pull

PrintInfo -message "Install/update chocolatey packages."
.\update-chocolatey.ps1

PrintInfo -message "Install/update Visual Studio 2019."
.\update-visualstudio.ps1

