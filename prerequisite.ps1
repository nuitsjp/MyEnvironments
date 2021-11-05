function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Message,
        [switch]
        $NoNewLine
    )
    if ($NoNewLine) {
        Write-Host -NoNewline $Message -ForegroundColor Cyan
    }
    else {
        Write-Host $Message -ForegroundColor Cyan
    }
}

function Install-PowerShellModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Name
    )
    Write-Log -NoNewLine "Check $Name..."
    if (($null -eq (Get-Module $Name -ListAvailable))) {
        Write-Log "Install $Name."
        Install-Module -Name $Name
    }
    else {
        Import-Module -Name $Name
        Write-Log "Already installed."
    }
}

function Install-WingetPackage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Id
    )
    Write-Log -NoNewLine "Check $Id..."
    if ((Invoke-WingetList -Id gerardog.gsudo).Length -eq 0) {
        Write-Log "Install $Id."
        winget install --id $Id
    }
    else {
        Write-Log "Already installed."
    }
}

Write-Log -NoNewLine "Check PSGallery InstallationPolicy..."
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -eq 'Untrusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Write-Log "InstallationPolicy is set to Trusted."
}
else {
    Write-Log "Already trusted."
}

Install-PowerShellModule powershell-yaml 
Install-PowerShellModule posh-winget

Write-Log -NoNewLine "Check gerardog.gsudo..."
if ((Invoke-WingetList -Id gerardog.gsudo).Length -eq 0) {
    Write-Log "Install gerardog.gsudo."
    winget install --id gerardog.gsudo
}
else {
    Write-Log "Already installed."
}

Write-Log -NoNewLine "Check Git.Git..."
if ((Invoke-WingetList -Id Git.Git).Length -eq 0) {
    Write-Log "Install Git.Git."
    winget install --id Git.Git
    
    Set-Item Env:Path "$Env:Path;$env:ProgramFiles\Git\cmd\"
    git config --global user.name "Atsushi Nakamura"
    git config --global user.email "nuits.jp@live.jp"
}
else {
    Write-Log "Already installed."
}

Write-Log -NoNewLine "Check Scancode Map..."
$keyboardLayoutPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
if ($null -eq ((Get-ItemProperty $keyboardLayoutPath)."Scancode Map")) {
    Write-Log -message "Replace Caps with Ctrl."
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
    Write-Log -message "Already Replaced."
}

Write-Log -NoNewLine "Check PowerShell execution policy..."
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
    Write-Log "Set PowerShell execution policy for current user."
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
}
else {
    Write-Log "Already Set."
}

Write-Log -NoNewLine "Check MyEnvironments..."
if (!(Test-Path C:\Repos\MyEnvironments)) {
    Write-Log "Clone MyEnvironments."
    if (!(Test-Path C:\Repos)) {
        New-Item -ItemType Directory C:\Repos > $null
    }

    git clone https://github.com/nuitsjp/MyEnvironments.git C:\Repos\MyEnvironments
}
else {
    Write-Log "Already cloned."
}

Write-Log -NoNewLine "Check chocolatey..."
if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
    Write-Log "Install chocolatey."
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
else {
    Write-Log "Already installed."
}

Write-Log -NoNewLine "Check Hyper-V..."
if (((Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq 'Microsoft-Hyper-V' })[0].State) -eq 'Disabled') {
    Write-Log "Enable Hyper-V. After enabled, reboot."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
}
else {
    Write-Log "Already enabled."
}

Read-Host -Prompt "Press any key to exit."