function PrintInfo($message) {
    Write-Host $message -ForegroundColor Cyan
}

PrintInfo -message "Install Visual Studio Code."
winget install Microsoft.VisualStudioCode -i

PrintInfo -message "Install JetBrains.Toolbox."
winget install JetBrains.Toolbox

PrintInfo -message "Install DockerDesktop."
winget install Docker.DockerDesktop

PrintInfo -message "Install VMware Workstation Pro."
winget install VMware.WorkstationPro
