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

PrintInfo -message "install/update Visual Studio 2019"
cd visualstudio
.\update.ps1
cd ..

