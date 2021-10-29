function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Message
    )
    Write-Host $Message -ForegroundColor Cyan
}

if(($null -eq (Get-Module posh-winget -ListAvailable))) {
    Write-Log 'install posh-winget.'
    Install-Module -Name posh-winget
}

$keyboardLayoutPath = "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
if($null -eq ((Get-ItemProperty $keyboardLayoutPath)."Scancode Map")) {
    Write-Log -message "Replace Caps with Ctrl."
    Set-ItemProperty `
        "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" `
        -name "Scancode Map" -value (`
            0x00,0x00,0x00,0x00,`
            0x00,0x00,0x00,0x00,`
            0x02,0x00,0x00,0x00,`
            0x1D,0x00,0x3A,0x00,`
            0x00,0x00,0x00,0x00 `
        ) -type binary
}

if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
    Write-Log "Set PowerShell execution policy for current user."
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

if(Install-Winget -Id Git.Git) {
    Write-Log "installed git."
}

if(((Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq 'Microsoft-Hyper-V' })[0].State) -eq 'Disabled') {
    Write-Log "Enable Hyper-V. After enabled, reboot."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
}

