function PrintInfo($message) {
  Write-Host $message -ForegroundColor Cyan
}

PrintInfo -message "Checking execution policy for current user."
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
  Set-ExecutionPolicy RemoteSigned -scope CurrentUser
}

PrintInfo -message "Checking chocolatey is installed."
if ($null -eq (Get-Command choco*)) {
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

PrintInfo -message "Install git."
choco install git.install -y --params="'/NoShellIntegration'"
git config --global user.email "nuits.jp@live.jp"
git config --global user.name "Atsushi Nakamura"

PrintInfo -message "Install gsudo."
choco install gsudo -y

PrintInfo -message "Enable Hyper-V. "
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

PrintInfo -message "Completed 'prerequisites.ps1'. Press Enter."
Read-Host
