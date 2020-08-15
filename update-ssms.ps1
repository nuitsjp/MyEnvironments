Remove-Item logs -Recurse -Force
Invoke-WebRequest -UseBasicParsing -Headers @{"Accept-Language" = "ja-jp"} -Uri https://aka.ms/ssmsfullsetup -OutFile SSMS-Setup-JPN.exe
Start-Process -FilePath SSMS-Setup-JPN.exe -ArgumentList "/install /passive /norestart /wait /log ssms-logs\log.txt" -Verb runas -Wait