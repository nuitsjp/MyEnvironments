function PrintInfo($message) {
  Write-Host $message -ForegroundColor Cyan
}

PrintInfo -message "add buckets to scoop."
foreach ($item in @("extras", "jetbrains")) {
  if (!((scoop bucket list) -contains $item)) {
    PrintInfo -message "add `"$item`" bucket to scoop."
    scoop bucket add $item
  }
}

PrintInfo -message "install/update scoop packages"
Scoop-Playbook