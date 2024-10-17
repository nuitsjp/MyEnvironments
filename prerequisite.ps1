Write-Host -NoNewLine "Check PSGallery InstallationPolicy..."
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -eq 'Untrusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Write-Host "InstallationPolicy is set to Trusted."
}
else {
    Write-Host "Already trusted."
}

Write-Host -NoNewLine "Check powershell-yaml..."
if (-not (Get-Module -Name powershell-yaml -ListAvailable)) {
    Write-Host "Install powershell-yaml."
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser -ErrorAction Stop
}
else {
    Write-Host "Already installed."
}
Import-Module -Name powershell-yaml

Write-Host -NoNewLine "Check posh-winget..."
if (-not (Get-Module -Name posh-winget -ListAvailable)) {
    Write-Host "Install posh-winget."
    Install-Module -Name posh-winget -Force -Scope CurrentUser -ErrorAction Stop
}
else {
    Write-Host "Already installed."
}
Import-Module -Name posh-winget

Write-Host -NoNewLine "Check Git.Git..."
if ((Invoke-WingetList -Id Git.Git).Length -eq 0) {
    Write-Host "Install Git.Git."
    winget install --id Git.Git
    
    Set-Item Env:Path "$Env:Path;$env:ProgramFiles\Git\cmd\"
    git config --global user.name "Atsushi Nakamura"
    git config --global user.email "nuits.jp@live.jp"
}
else {
    Write-Host "Already installed."
}

Write-Host -NoNewLine "Check Scancode Map..."
$keyboardLayoutPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
if ($null -eq ((Get-ItemProperty $keyboardLayoutPath)."Scancode Map")) {
    Write-Host -message "Replace Caps with Ctrl."
    Set-ItemProperty `
        "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" `
        -name "Scancode Map" -value (`
            0x00, 0x00, 0x00, 0x00, `
            0x00, 0x00, 0x00, 0x00, `
            0x02, 0x00, 0x00, 0x00, `
            0x1D, 0x00, 0x3A, 0x00, `
            0x00, 0x00, 0x00, 0x00 `
    ) -type binary
}
else {
    Write-Host -message "Already Replaced."
}

Write-Host -NoNewLine "Check PowerShell execution policy..."
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
    Write-Host "Set PowerShell execution policy for current user."
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
}
else {
    Write-Host "Already Set."
}

Write-Host -NoNewLine "Check MyEnvironments..."
if (!(Test-Path C:\Repos\MyEnvironments)) {
    Write-Host "Clone MyEnvironments."
    if (!(Test-Path C:\Repos)) {
        New-Item -ItemType Directory C:\Repos > $null
    }

    git clone https://github.com/nuitsjp/MyEnvironments.git C:\Repos\MyEnvironments
}
else {
    Write-Host "Already cloned."
}

Write-Host -NoNewLine "Check chocolatey..."
if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
    Write-Host "Install chocolatey."
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
else {
    Write-Host "Already installed."
}

Write-Host -NoNewLine "Check Hyper-V..."
if (((Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq 'Microsoft-Hyper-V' })[0].State) -eq 'Disabled') {
    Write-Host "Enable Hyper-V. After enabled, reboot."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
}
else {
    Write-Host "Already enabled."
}

Read-Host -Prompt "Press any key to exit."
