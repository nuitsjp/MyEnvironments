Install-Module powershell-yaml

$config = Get-Content -Path (Join-Path $PSScriptRoot winget.yml) | ConvertFrom-Yaml
$config | Sort-Object {$_.id} | ConvertTo-Yaml | Set-Content -Path (Join-Path $PSScriptRoot winget.yml)

# $config | ForEach-Object {
#     $package = $_
#     $list = winget list --id $package.id
#     $lines = ($list | Measure-Object -Line).Lines
#     if($lines -lt 5) {
#         $arguments = @()
#         $arguments += 'install'
#         if($package.silent -ne $false) {
#             $arguments += '--silent'
#         }
#         $arguments += '--id'
#         $arguments += $package.id

#         if($package.packageParameters -ne $null) {
#             $arguments += '--override'
#             $arguments += "`"$($package.packageParameters)`""
#         }

#         $argumentList = [string]::Join(' ', $arguments)
#         Start-Process winget -NoNewWindow -Wait -ArgumentList $argumentList
#         # winget install --silent --id $package.id
#     } else {
#         Write-Host "$($package.id) is installed."
#     }
# }