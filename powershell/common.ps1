function Use-TempDir {
    param (
        [ScriptBlock]$Script
    )
    $tmp = $env:TEMP | Join-Path -ChildPath $([System.Guid]::NewGuid().Guid)
    New-Item -ItemType Directory -Path $tmp | Push-Location
    try {
        Invoke-Command -ScriptBlock $script
    }
    finally {
        Pop-Location
        $tmp | Remove-Item -Recurse
    }
}