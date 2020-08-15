function PrintInfo($message) {
  Write-Host $message -ForegroundColor Cyan
}

PrintInfo -message "checking execution policy for current user."
if ((Get-ExecutionPolicy -Scope CurrentUser) -ne "RemoteSigned") {
  Set-ExecutionPolicy RemoteSigned -scope CurrentUser
}
PrintInfo -message "checking scoop is installed."
if ($null -eq (Get-Command scoop.ps1*)) {
  iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
}

PrintInfo -message "install/update required scoop package"
foreach ($item in @("git", "sudo")) {
  scoop install $item
  scoop update $item
  if (!$?) {
    PrintInfo -message "COULD NOT COMPLETE INSTALLATION $item. please run 'scoop uninstall $item' then run again."
    return
  }
}

PrintInfo -message "update and check scoop"
scoop update
scoop checkup

PrintInfo -message "Exclude scoop path from Microsoft Defender."
foreach ($item in @("$env:UserProfile\scoop", "$env:ProgramData\scoop")) {
  if (!((Get-MpPreference).ExclusionPath -contains $item)) {
    sudo Add-MpPreference -ExclusionPath $item
  }
}

PrintInfo -message "Set longpath support."
if (1 -ne (Get-ItemPropertyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled')) {
  sudo Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
}
