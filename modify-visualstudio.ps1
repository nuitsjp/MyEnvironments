function PrintInfo($message) {
  Write-Host $message -ForegroundColor Cyan
}

PrintInfo -message "Modify Visual Studio 2019"
Invoke-WebRequest -UseBasicParsing -Uri http://aka.ms/vs/16/release/vs_enterprise.exe -OutFile vs_enterprise.exe
Start-Process -FilePath vs_enterprise.exe -ArgumentList "modify --config `"${pwd}\.vsconfig`" --passive --norestart --wait" -Verb runas -Wait
