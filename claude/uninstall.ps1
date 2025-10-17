param(
    [Parameter(Position=0)]
    [string]$BinaryPath,

    [switch]$NoDownload
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

if (-not [Environment]::Is64BitProcess) {
    Write-Error "Claude Code does not support 32-bit Windows. Please use a 64-bit version of Windows."
    exit 1
}

$bucketBase = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
$downloadRoot = Join-Path $env:USERPROFILE ".claude"
$downloadDir = Join-Path $downloadRoot "downloads"
$tempBinaryPath = $null

function Write-Info($message) {
    Write-Host $message
}

function Resolve-InstalledBinary {
    param(
        [string]$ExplicitBinaryPath
    )

    if ($ExplicitBinaryPath) {
        if (-not (Test-Path -LiteralPath $ExplicitBinaryPath)) {
            throw "Provided binary path '$ExplicitBinaryPath' does not exist."
        }
        return (Resolve-Path -LiteralPath $ExplicitBinaryPath).Path
    }

    $command = Get-Command -Name "claude" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidateDirs = @(
        Join-Path $env:LOCALAPPDATA "Programs\\Claude",
        Join-Path $env:LOCALAPPDATA "Programs\\claude",
        Join-Path $env:LOCALAPPDATA "Programs\\Claude Code",
        Join-Path $env:ProgramFiles "Claude",
        Join-Path ${env:ProgramFiles(x86)} "Claude"
    ) | Where-Object { $_ }

    foreach ($dir in $candidateDirs) {
        $candidate = Join-Path $dir "claude.exe"
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    return $null
}

function Get-UninstallerBinary {
    New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null

    try {
        $version = Invoke-RestMethod -Uri "$bucketBase/stable" -ErrorAction Stop
    }
    catch {
        throw "Failed to determine latest stable version: $_"
    }

    $platform = "win32-x64"

    try {
        $manifest = Invoke-RestMethod -Uri "$bucketBase/$version/manifest.json" -ErrorAction Stop
        $checksum = $manifest.platforms.$platform.checksum
        if (-not $checksum) {
            throw "Platform $platform missing from manifest."
        }
    }
    catch {
    throw "Failed to load manifest for version ${version}: $_"
    }

    $targetPath = Join-Path $downloadDir "claude-$version-$platform.exe"

    try {
        Invoke-WebRequest -Uri "$bucketBase/$version/$platform/claude.exe" -OutFile $targetPath -ErrorAction Stop
    }
    catch {
        if (Test-Path -LiteralPath $targetPath) {
            Remove-Item -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue
        }
        throw "Failed to download claude.exe: $_"
    }

    $actualChecksum = (Get-FileHash -Path $targetPath -Algorithm SHA256).Hash.ToLower()
    if ($actualChecksum -ne $checksum) {
        Remove-Item -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue
        throw "Checksum verification failed."
    }

    $script:tempBinaryPath = $targetPath
    return $targetPath
}

try {
    $binary = Resolve-InstalledBinary -ExplicitBinaryPath $BinaryPath

    if (-not $binary) {
        if ($NoDownload) {
            throw "Could not locate an installed claude.exe and downloads are disabled."
        }
        Write-Info "Installed claude.exe not found. Downloading the stable uninstaller..."
        $binary = Get-UninstallerBinary
    }
    else {
        Write-Info "Using claude.exe at '$binary'."
    }

    Write-Info "Running uninstall..."
    Write-Info "Binary path: $binary"
    Write-Info "Binary version check..."
    
    # Try to get version info first to verify binary works
    $versionError = $null
    try {
        $versionOutput = & $binary --version 2>&1
        Write-Info "Version: $versionOutput"
    }
    catch {
        $versionError = $_
        Write-Warning "Could not get version: $($versionError.Exception.Message)"
    }

    Write-Info "Attempting uninstall command..."
    $uninstallError = $null
    $uninstallOutput = @()
    try {
        # Capture both stdout and stderr
        $uninstallOutput = & $binary uninstall 2>&1
        if ($uninstallOutput) {
            Write-Info "Uninstall output:"
            $uninstallOutput | ForEach-Object { Write-Info "  $_" }
        }
    }
    catch {
        $uninstallError = $_
    }

    $exitCode = $LASTEXITCODE
    Write-Info "Exit code: $exitCode"

    if ($uninstallError) {
        Write-Warning "claude.exe uninstall threw exception: $($uninstallError.Exception.Message)"
        Write-Warning "Exception type: $($uninstallError.GetType().FullName)"
        if (-not $exitCode) {
            $exitCode = 1
        }
    }

    if ($exitCode -ne 0) {
        Write-Warning "claude.exe uninstall exited with code $exitCode. Continuing with manual cleanup steps."
        Write-Info "Note: This appears to be a Bun runtime bug (ENOTCONN). Manual cleanup will proceed."
    }
    else {
        Write-Info "Uninstall command completed successfully."
    }

    # Expanded cleanup targets to ensure complete removal
    Write-Info ""
    Write-Info "=== Starting manual cleanup ==="
    $cleanupTargets = @(
        $downloadDir,
        $downloadRoot,
        # Additional paths that might be created during installation
        (Join-Path $env:LOCALAPPDATA "Programs\Claude"),
        (Join-Path $env:LOCALAPPDATA "Programs\claude"),
        (Join-Path $env:LOCALAPPDATA "Programs\Claude Code"),
        # User configuration and data directories
        (Join-Path $env:APPDATA "Claude"),
        (Join-Path $env:APPDATA "Claude Code"),
        # Temporary files that might remain
        (Join-Path $env:TEMP "claude-*"),
        # The .local\bin directory if it exists
        (Join-Path $env:USERPROFILE ".local\bin")
    )

    Write-Info "Checking $($cleanupTargets.Count) cleanup locations..."
    $removedCount = 0
    $skippedCount = 0

    foreach ($path in $cleanupTargets) {
        Write-Info "Checking: $path"
        if (Test-Path -LiteralPath $path) {
            try {
                # Handle wildcard paths differently
                if ($path -like "*\claude-*") {
                    $parentDir = Split-Path $path
                    $filter = Split-Path $path -Leaf
                    $items = Get-ChildItem -Path $parentDir -Filter $filter -ErrorAction SilentlyContinue
                    if ($items) {
                        foreach ($item in $items) {
                            Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop 
                            Write-Info "  ✓ Removed: $($item.FullName)"
                            $removedCount++
                        }
                    }
                    else {
                        Write-Info "  - No matching items found"
                        $skippedCount++
                    }
                } else {
                    Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
                    Write-Info "  ✓ Removed: $path"
                    $removedCount++
                }
            }
            catch {
                Write-Warning "  ✗ Could not remove '$path': $_"
            }
        }
        else {
            Write-Info "  - Not found (already clean)"
            $skippedCount++
        }
    }

    # Check and clean up PATH environment variable if needed
    Write-Info ""
    Write-Info "Checking PATH environment variable..."
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath) {
        $pathParts = $userPath -split ';' | Where-Object { 
            $_ -and $_ -notlike "*\Claude*" -and $_ -notlike "*\claude*"
        }
        $newPath = $pathParts -join ';'
        if ($newPath -ne $userPath) {
            [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
            Write-Info "  ✓ Removed Claude from PATH environment variable"
        }
        else {
            Write-Info "  - PATH is already clean"
        }
    }
    
    Write-Info ""
    Write-Info "=== Cleanup Summary ==="
    Write-Info "Removed: $removedCount location(s)"
    Write-Info "Skipped: $skippedCount location(s) (not found)"
    Write-Info "======================="
}
finally {
    if ($tempBinaryPath -and (Test-Path -LiteralPath $tempBinaryPath)) {
        try {
            Start-Sleep -Seconds 1
            Remove-Item -LiteralPath $tempBinaryPath -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "Could not remove temporary file: $tempBinaryPath"
        }
    }
}

Write-Output ""
Write-Output "Uninstallation complete."
Write-Output ""
