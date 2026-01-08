function Sync-UserHome {
    $sourceDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\windows\home"))
    $destDir = $env:USERPROFILE

    if (-not (Test-Path $sourceDir)) {
        Write-Warning "Source directory not found: $sourceDir"
        return
    }

    Copy-Item -Path "$sourceDir\*" -Destination $destDir -Recurse -Force
    Write-Host "Synced files from $sourceDir to $destDir"
}

Set-Alias -Name sync-home -Value Sync-UserHome
