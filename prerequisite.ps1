function PrintInfo($message) {
  Write-Host $message -ForegroundColor Cyan
}

PrintInfo -message "Replace Caps with Ctrl."
  Set-ItemProperty `
  "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" `
  -name "Scancode Map" -value (`
    0x00,0x00,0x00,0x00,`
    0x00,0x00,0x00,0x00,`
    0x02,0x00,0x00,0x00,`
    0x1D,0x00,0x3A,0x00,`
    0x00,0x00,0x00,0x00 `
  ) -type binary

PrintInfo -message "Checking execution policy for current user."
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
  Set-ExecutionPolicy RemoteSigned -scope CurrentUser
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

PrintInfo -message "Install git."
winget install Git.Git

PrintInfo -message "Install gsudo."
winget install gerardog.gsudo

PrintInfo -message "Enable Hyper-V. After enabled, reboot."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
