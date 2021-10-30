. $PSScriptRoot\..\powershell\common.ps1

function Install-SSMS {
    if(!(Test-Ssms)) {
        Write-Host 'Install SQL Server Management Studio.' -ForegroundColor Cyan
        Use-TempDir {
            $Headers = @{
                "Accept-Language" = "ja-jp"
            }
            Invoke-WebRequest -UseBasicParsing -Headers $Headers -Uri https://aka.ms/ssmsfullsetup -OutFile SSMS-Setup-JPN.exe
            Start-Process -FilePath SSMS-Setup-JPN.exe -ArgumentList "/install /quiet /passive /norestart" -Verb runas -Wait
        }
    }
    else {
        Write-Host 'SQL Server Management Studio is installed.' -ForegroundColor Cyan
    }
}

function Update-SSMS {
    if((Get-SsmsVersionOfLocal) -ne (Get-SsmsVersionOfWinget))
    {
        Write-Host 'Update SQL Server Management Studio.' -ForegroundColor Cyan
        Use-TempDir {
            $Headers = @{
                "Accept-Language" = "ja-jp"
            }
            Invoke-WebRequest -UseBasicParsing -Headers $Headers -Uri https://aka.ms/ssmsfullsetup -OutFile SSMS-Setup-JPN.exe
            Start-Process -FilePath SSMS-Setup-JPN.exe -ArgumentList "/install /quiet /passive /norestart" -Verb runas -Wait
        }
    }
    else {
        Write-Host 'SQL Server Management Studio is up to date.' -ForegroundColor Cyan
    }
}

function Get-SsmsVersionOfLocal {
    $ssms = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
        Where-Object {$_.DisplayName -like 'Microsoft SQL Server Management Studio*'} | `
        Select-Object DisplayName, DisplayVersion
    if($ssms) {
        $ssms.DisplayVersion
    }
    else {
        $null
    }
}

function Test-Ssms {
    $ssms = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
        Where-Object {$_.DisplayName -like 'Microsoft SQL Server Management Studio*'} | `
        Select-Object DisplayName, DisplayVersion
    if($ssms) {
        $true
    }
    else {
        $false
    }
}

function Get-SsmsVersionOfWinget {
    $wingetSsms = (winget search --id 'Microsoft.SQLServerManagementStudio') -split "`r`n"
    $wingetSsmsVertion = $wingetSsms[3].SubString($wingetSsms[3].IndexOf(' ', $wingetSsms[3].IndexOf('Microsoft.SQLServerManagementStudio')) + 1)
    $wingetSsmsVertion.SubString(0, $wingetSsmsVertion.IndexOf(' '))
}
