Invoke-WebRequest -UseBasicParsing -Uri http://aka.ms/vs/16/release/vs_professional.exe -OutFile vs_Professional.exe
Start-Process -FilePath vs_Professional.exe -ArgumentList "--add Microsoft.VisualStudio.Workload.CoreEditor --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.Universal --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.VisualStudioExtension --add Microsoft.VisualStudio.Workload.NetCoreTools --add Microsoft.VisualStudio.Workload.Office --add Component.GitHub.VisualStudio --passive --norestart" -Verb runas -Wait
