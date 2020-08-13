function PrintInfo($message) {
  Write-Host $message -ForegroundColor Cyan
}

PrintInfo -message "update git repository"
git pull

PrintInfo -message "install/update scoop packages"
cd scoop
try
{
  .\update.ps1
}
finally
{
  cd ..
}


