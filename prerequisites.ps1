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
}

PrintInfo -message "Checking chocolatey is installed."
if ($null -eq (Get-Command choco*)) {
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

PrintInfo -message "Install git."
winget install Git.Git
git config --global user.email "nuits.jp@live.jp"
git config --global user.name "Atsushi Nakamura"

PrintInfo -message "Install gsudo."
winget install gerardog.gsudo

PrintInfo -message "Enable Hyper-V."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

PrintInfo -message "Completed 'prerequisites.ps1'. Press Enter to log off."
Read-Host
shutdown /l /f
