. $PSScriptRoot\ssms\ssms.ps1

# $ssms = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
#     Where-Object {$_.DisplayName -like 'Microsoft SQL Server Management Studio*'} | `
#     Select-Object DisplayName, DisplayVersion
# if($ssms) {
#     $ssms.DisplayVersion
# }
# else {
#     "NG"
# }

Install-SSMS
# Get-SsmsVersionOfLocal
# Get-SsmsVersionOfWinget