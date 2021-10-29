function PrintInfo($message) {
  Write-Host $message -ForegroundColor Cyan
}

if (0 -eq ((vswhere -utf8 -format json | ConvertFrom-Json).Length))
{
  PrintInfo -message "install Visual Studio 2019"
  Invoke-WebRequest -UseBasicParsing -Uri http://aka.ms/vs/16/release/vs_enterprise.exe -OutFile vs_enterprise.exe
  Start-Process -FilePath vs_enterprise.exe -ArgumentList "--config `"${pwd}\.vsconfig`" --passive --norestart --wait" -Verb runas -Wait
} 
else
{
  PrintInfo -message "update Visual Studio 2019"
  Invoke-WebRequest -UseBasicParsing -Uri http://aka.ms/vs/16/release/vs_enterprise.exe -OutFile vs_enterprise.exe
  Start-Process -FilePath vs_enterprise.exe -ArgumentList "update --passive --norestart --wait" -Verb runas -Wait
}