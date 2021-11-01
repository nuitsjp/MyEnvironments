. $PSScriptRoot\visualstudio\visualstudio.ps1

$poshWinget = 'C:\Repos\posh-winget'
if (Test-Path $poshWinget) {
    Remove-Item  $poshWinget -Recurse -Force
}

winget install Git.Git

$git = Join-Path $env:ProgramFiles 'Git\bin\git.exe'
Start-Process -FilePath $git -Wait -ArgumentList "clone https://github.com/nuitsjp/posh-winget.git C:\Repos\posh-winget" -NoNewWindow
