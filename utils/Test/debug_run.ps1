. "$PSScriptRoot\..\Remove-InvalidPath.ps1"

$r = Get-UserPathEntries -RawPathString 'C:\One;C:\Two;C:\One'
if ($null -eq $r) { Write-Host 'NULL' } else { Write-Host "Count=$($r.Count)"; $r | ForEach-Object { Write-Host $_ } } 
 
# Define a local function override to simulate Mock
function Normalize-PathEntry { param($p); switch ($p) { 'C:\One' { 'C:\OneNorm' } 'C:\Two' { 'C:\TwoNorm' } default { $null } } }
$r2 = Get-UserPathEntries -RawPathString 'C:\One;C:\Two;C:\One'
Write-Host "After override:" 
if ($null -eq $r2) { Write-Host 'NULL' } else { Write-Host "Count=$($r2.Count)"; $r2 | ForEach-Object { Write-Host $_ } }
