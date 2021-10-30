function Install-ChocolateryPackage {
    Write-Host 'Install chocolatery packages.' -ForegroundColor Cyan
    choco install $PSScriptRoot\chocolatery.config -y
}

function Update-ChocolateryPackage {
    Write-Host 'Install chocolatery packages.' -ForegroundColor Cyan
    choco install $PSScriptRoot\chocolatery.config -y
    Write-Host 'Upgrade chocolatery packages.' -ForegroundColor Cyan
    choco upgrade all -y
}
