$Headers = @{
        "Accept-Language" = "ja-jp"
    }
Invoke-WebRequest -UseBasicParsing -Headers $Headers -Uri https://aka.ms/ssmsfullsetup -OutFile SSMS-Setup-JPN.exe
Start-Process -FilePath SSMS-Setup-JPN.exe -ArgumentList "/install /quiet /passive /norestart" -Verb runas -Wait
