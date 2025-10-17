param(
    [switch]$FullScan,
    [switch]$ShowDetails
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$ProgressPreference = 'SilentlyContinue'

Write-Host "=== Claude File Checker ===" -ForegroundColor Cyan
Write-Host ""

$foundFiles = @()
$foundDirs = @()
$scannedLocations = 0

function Write-Status($message) {
    Write-Host "[*] $message" -ForegroundColor Yellow
}

function Write-Found($message) {
    Write-Host "[!] FOUND: $message" -ForegroundColor Red
}

function Write-Clean($message) {
    Write-Host "[✓] $message" -ForegroundColor Green
}

# 優先度の高い検索場所
$priorityLocations = @(
    # User directories
    "$env:USERPROFILE\.local\bin",
    "$env:USERPROFILE\.local",
    "$env:USERPROFILE\.claude",
    "$env:LOCALAPPDATA\Programs\Claude",
    "$env:LOCALAPPDATA\Programs\claude",
    "$env:LOCALAPPDATA\Programs\Claude Code",
    "$env:APPDATA\Claude",
    "$env:APPDATA\Claude Code",
    "$env:TEMP",
    # System directories
    "$env:ProgramFiles\Claude",
    "${env:ProgramFiles(x86)}\Claude",
    "$env:SystemDrive\Claude",
    # Common installation paths
    "$env:LOCALAPPDATA\Microsoft\WindowsApps"
)

Write-Status "Scanning priority locations..."
Write-Host ""

foreach ($location in $priorityLocations) {
    if (Test-Path $location) {
        $scannedLocations++
        Write-Status "Checking: $location"
        
        try {
            # Search for claude-related files
            $files = Get-ChildItem -Path $location -Recurse -ErrorAction SilentlyContinue | 
                Where-Object { 
                    $_.Name -like "*claude*" -and 
                    -not ($_.FullName -like "*\check-claude-files.ps1*") -and
                    -not ($_.FullName -like "*\uninstall.ps1*") -and
                    -not ($_.FullName -like "*\install.ps1*")
                }
            
            if ($files) {
                foreach ($file in $files) {
                    if ($file.PSIsContainer) {
                        $foundDirs += $file.FullName
                        Write-Found "Directory: $($file.FullName)"
                        if ($ShowDetails) {
                            Write-Host "    Type: Directory" -ForegroundColor Gray
                            Write-Host "    Created: $($file.CreationTime)" -ForegroundColor Gray
                        }
                    }
                    else {
                        $foundFiles += $file.FullName
                        Write-Found "File: $($file.FullName)"
                        if ($ShowDetails) {
                            Write-Host "    Size: $([math]::Round($file.Length / 1KB, 2)) KB" -ForegroundColor Gray
                            Write-Host "    Modified: $($file.LastWriteTime)" -ForegroundColor Gray
                        }
                    }
                }
            }
        }
        catch {
            Write-Host "    [Skip] Access denied or error: $_" -ForegroundColor DarkGray
        }
    }
}

Write-Host ""

# PATH環境変数のチェック
Write-Status "Checking PATH environment variables..."
$pathIssues = @()

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath) {
    $userPathParts = $userPath -split ';' | Where-Object { $_ -like "*claude*" -or $_ -like "*Claude*" }
    if ($userPathParts) {
        foreach ($part in $userPathParts) {
            $pathIssues += "User PATH: $part"
            Write-Found "PATH entry: $part (User)"
        }
    }
}

$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($machinePath) {
    $machinePathParts = $machinePath -split ';' | Where-Object { $_ -like "*claude*" -or $_ -like "*Claude*" }
    if ($machinePathParts) {
        foreach ($part in $machinePathParts) {
            $pathIssues += "Machine PATH: $part"
            Write-Found "PATH entry: $part (Machine)"
        }
    }
}

if (-not $pathIssues) {
    Write-Clean "No Claude entries in PATH"
}

Write-Host ""

# レジストリチェック (Windowsのインストール情報)
Write-Status "Checking Windows Registry..."
$regPaths = @(
    "HKCU:\Software\Claude",
    "HKLM:\Software\Claude",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$foundRegistry = @()
foreach ($regPath in $regPaths) {
    try {
        if ($regPath -like "*Uninstall*") {
            $items = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | 
                Where-Object { $_.DisplayName -like "*Claude*" }
            foreach ($item in $items) {
                $foundRegistry += "$($item.PSPath) - $($item.DisplayName)"
                Write-Found "Registry: $($item.DisplayName) at $($item.PSPath)"
            }
        }
        else {
            if (Test-Path $regPath) {
                $foundRegistry += $regPath
                Write-Found "Registry key: $regPath"
            }
        }
    }
    catch {
        # Silently skip inaccessible registry keys
    }
}

if (-not $foundRegistry) {
    Write-Clean "No Claude entries in Registry"
}

Write-Host ""

# フルスキャン (オプション)
if ($FullScan) {
    Write-Status "Performing FULL SCAN of C:\ (this may take several minutes)..."
    Write-Host ""
    
    try {
        $fullScanFiles = Get-ChildItem -Path "C:\" -Recurse -ErrorAction SilentlyContinue |
            Where-Object { 
                $_.Name -like "*claude*" -and 
                -not ($_.FullName -like "*\check-claude-files.ps1*") -and
                -not ($_.FullName -like "*\uninstall.ps1*") -and
                -not ($_.FullName -like "*\install.ps1*") -and
                -not ($_.FullName -like "*D:\Temp*")
            }
        
        foreach ($file in $fullScanFiles) {
            $fullPath = $file.FullName
            # Skip already found files
            if ($foundFiles -notcontains $fullPath -and $foundDirs -notcontains $fullPath) {
                if ($file.PSIsContainer) {
                    $foundDirs += $fullPath
                    Write-Found "Directory: $fullPath"
                }
                else {
                    $foundFiles += $fullPath
                    Write-Found "File: $fullPath"
                }
            }
        }
    }
    catch {
        Write-Host "[!] Full scan error: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "[i] For a complete C:\ drive scan, run with -FullScan parameter" -ForegroundColor Cyan
    Write-Host "    (Warning: Full scan may take 5-10 minutes)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Scanned priority locations: $scannedLocations"
Write-Host "Files found: $($foundFiles.Count)" -ForegroundColor $(if ($foundFiles.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Directories found: $($foundDirs.Count)" -ForegroundColor $(if ($foundDirs.Count -eq 0) { "Green" } else { "Red" })
Write-Host "PATH issues: $($pathIssues.Count)" -ForegroundColor $(if ($pathIssues.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Registry entries: $($foundRegistry.Count)" -ForegroundColor $(if ($foundRegistry.Count -eq 0) { "Green" } else { "Red" })
Write-Host ""

$totalIssues = $foundFiles.Count + $foundDirs.Count + $pathIssues.Count + $foundRegistry.Count

if ($totalIssues -eq 0) {
    Write-Host "✓ System is CLEAN - No Claude-related files found!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "⚠ Found $totalIssues Claude-related item(s)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To remove these items, you can:" -ForegroundColor Cyan
    Write-Host "1. Manually delete the files/directories listed above" -ForegroundColor Cyan
    Write-Host "2. Run this script with elevated permissions if access was denied" -ForegroundColor Cyan
    exit 1
}
