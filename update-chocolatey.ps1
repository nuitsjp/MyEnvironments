function PrintInfo($message) {
  Write-Host $message -ForegroundColor Cyan
}

choco install chocolatery.config -y
choco upgrade all -y