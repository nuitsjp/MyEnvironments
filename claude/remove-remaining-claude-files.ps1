param(
    [switch]$WhatIf,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "=== Claude Remaining Files Remover ===" -ForegroundColor Cyan
Write-Host ""

if ($WhatIf) {
    Write-Host "[DRY RUN MODE] - No files will be deleted" -ForegroundColor Yellow
    Write-Host ""
}

$removedCount = 0
$failedCount = 0
$skippedCount = 0

function Remove-SafeItem {
    param(
        [string]$Path,
        [string]$Description
    )
    
    Write-Host "[*] Checking: $Description" -ForegroundColor Cyan
    Write-Host "    Path: $Path" -ForegroundColor Gray
    
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host "    [✓] Already removed" -ForegroundColor Green
        $script:skippedCount++
        return
    }
    
    if ($WhatIf) {
        Write-Host "    [WOULD DELETE] This item would be deleted" -ForegroundColor Yellow
        return
    }
    
    try {
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
        Write-Host "    [✓] Successfully removed" -ForegroundColor Green
        $script:removedCount++
    }
    catch {
        Write-Host "    [✗] Failed: $_" -ForegroundColor Red
        $script:failedCount++
    }
    
    Write-Host ""
}

function Remove-RegistryKey {
    param(
        [string]$Path,
        [string]$Description
    )
    
    Write-Host "[*] Checking: $Description" -ForegroundColor Cyan
    Write-Host "    Path: $Path" -ForegroundColor Gray
    
    if (-not (Test-Path -Path $Path)) {
        Write-Host "    [✓] Already removed" -ForegroundColor Green
        $script:skippedCount++
        return
    }
    
    if ($WhatIf) {
        Write-Host "    [WOULD DELETE] This registry key would be deleted" -ForegroundColor Yellow
        return
    }
    
    try {
        Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
        Write-Host "    [✓] Successfully removed" -ForegroundColor Green
        $script:removedCount++
    }
    catch {
        Write-Host "    [✗] Failed: $_" -ForegroundColor Red
        $script:failedCount++
    }
    
    Write-Host ""
}

# Confirmation
if (-not $WhatIf -and -not $Force) {
    Write-Host "This script will remove the following Claude-related items:" -ForegroundColor Yellow
    Write-Host "  - User data and configuration files" -ForegroundColor Yellow
    Write-Host "  - Temporary files" -ForegroundColor Yellow
    Write-Host "  - VS Code extensions (anthropic.claude-code)" -ForegroundColor Yellow
    Write-Host "  - Registry entries" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "VS Code extensions will be removed. To prevent this, exit and use -WhatIf first." -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Do you want to continue? (yes/no)"
    
    if ($response -ne "yes") {
        Write-Host "Aborted by user." -ForegroundColor Red
        exit 1
    }
    Write-Host ""
}

Write-Host "=== Removing User Data ===" -ForegroundColor Cyan
Write-Host ""

Remove-SafeItem -Path "C:\Users\$env:USERNAME\.local\share\claude" -Description "Claude shared data"
Remove-SafeItem -Path "C:\Users\$env:USERNAME\.local\state\claude" -Description "Claude state data"
Remove-SafeItem -Path "C:\Users\$env:USERNAME\.claude.json" -Description "Claude configuration file"
Remove-SafeItem -Path "C:\Users\$env:USERNAME\.claude.json.backup" -Description "Claude configuration backup"
Remove-SafeItem -Path "C:\Users\$env:USERNAME\.cache\claude" -Description "Claude cache"

Write-Host "=== Removing Temporary Files ===" -ForegroundColor Cyan
Write-Host ""

# Remove claude-*-cwd temp files
$tempFiles = Get-ChildItem -Path "$env:TEMP" -Filter "claude-*-cwd" -ErrorAction SilentlyContinue
if ($tempFiles) {
    Write-Host "[*] Found $($tempFiles.Count) temporary cwd files" -ForegroundColor Cyan
    foreach ($file in $tempFiles) {
        if ($WhatIf) {
            Write-Host "    [WOULD DELETE] $($file.FullName)" -ForegroundColor Yellow
        }
        else {
            try {
                Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
                Write-Host "    [✓] Removed: $($file.Name)" -ForegroundColor Green
                $removedCount++
            }
            catch {
                Write-Host "    [✗] Failed: $($file.Name) - $_" -ForegroundColor Red
                $failedCount++
            }
        }
    }
}
else {
    Write-Host "[✓] No temporary cwd files found" -ForegroundColor Green
    $skippedCount++
}
Write-Host ""

# Remove WinGet cache
Remove-SafeItem -Path "$env:LOCALAPPDATA\Temp\WinGet\cache\V2_M\Microsoft.Winget.Source_8wekyb3d8bbwe\manifests\a\Anthropic\Claude" -Description "WinGet manifest cache (Claude)"
Remove-SafeItem -Path "$env:LOCALAPPDATA\Temp\WinGet\cache\V2_M\Microsoft.Winget.Source_8wekyb3d8bbwe\manifests\a\Anthropic\ClaudeCode" -Description "WinGet manifest cache (ClaudeCode)"
Remove-SafeItem -Path "$env:LOCALAPPDATA\Temp\WinGet\cache\V2_PVD\Microsoft.Winget.Source_8wekyb3d8bbwe\packages\Anthropic.Claude" -Description "WinGet package cache (Claude)"
Remove-SafeItem -Path "$env:LOCALAPPDATA\Temp\WinGet\cache\V2_PVD\Microsoft.Winget.Source_8wekyb3d8bbwe\packages\Anthropic.ClaudeCode" -Description "WinGet package cache (ClaudeCode)"

Write-Host "=== Removing VS Code Extensions ===" -ForegroundColor Cyan
Write-Host ""

# Find all anthropic.claude-code extensions
$vscodeExtensions = @(
    "C:\Users\$env:USERNAME\.vscode\extensions\anthropic.claude-code-2.0.17",
    "C:\Users\$env:USERNAME\.vscode\extensions\anthropic.claude-code-2.0.21",
    "C:\Users\$env:USERNAME\.vscode-insiders\extensions\anthropic.claude-code-1.0.70"
)

# Also search for any other versions
$vscodeExtensionDirs = @(
    "C:\Users\$env:USERNAME\.vscode\extensions",
    "C:\Users\$env:USERNAME\.vscode-insiders\extensions"
)

$foundExtensions = @()
foreach ($dir in $vscodeExtensionDirs) {
    if (Test-Path $dir) {
        $extensions = Get-ChildItem -Path $dir -Directory -Filter "anthropic.claude-code-*" -ErrorAction SilentlyContinue
        foreach ($ext in $extensions) {
            if ($vscodeExtensions -notcontains $ext.FullName) {
                $foundExtensions += $ext.FullName
            }
        }
    }
}

$allExtensions = $vscodeExtensions + $foundExtensions

foreach ($ext in $allExtensions) {
    Remove-SafeItem -Path $ext -Description "VS Code extension: $(Split-Path $ext -Leaf)"
}

Write-Host "=== Removing Registry Entries ===" -ForegroundColor Cyan
Write-Host ""

Remove-RegistryKey -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\AnthropicClaude" -Description "Claude uninstall registry entry"

# Check for additional Claude registry keys
$additionalRegKeys = @(
    "HKCU:\Software\Claude",
    "HKCU:\Software\Anthropic"
)

foreach ($regKey in $additionalRegKeys) {
    if (Test-Path $regKey) {
        Remove-RegistryKey -Path $regKey -Description "Claude registry key: $regKey"
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Removed: $removedCount item(s)" -ForegroundColor $(if ($removedCount -gt 0) { "Green" } else { "Gray" })
Write-Host "Skipped: $skippedCount item(s) (already clean)" -ForegroundColor $(if ($skippedCount -gt 0) { "Green" } else { "Gray" })
Write-Host "Failed: $failedCount item(s)" -ForegroundColor $(if ($failedCount -gt 0) { "Red" } else { "Gray" })
Write-Host ""

if ($WhatIf) {
    Write-Host "This was a dry run. To actually delete files, run without -WhatIf" -ForegroundColor Yellow
}
elseif ($failedCount -eq 0 -and $removedCount -gt 0) {
    Write-Host "✓ Cleanup completed successfully!" -ForegroundColor Green
}
elseif ($removedCount -eq 0 -and $skippedCount -gt 0) {
    Write-Host "✓ System is already clean!" -ForegroundColor Green
}
elseif ($failedCount -gt 0) {
    Write-Host "⚠ Cleanup completed with some errors. Check the output above." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Note: The following items were NOT removed as they are unrelated to Claude Code:" -ForegroundColor Cyan
Write-Host "  - CyberLink PowerDVD audio encoder files (claudenc.ax)" -ForegroundColor Gray
Write-Host "  - Visual Studio documentation about Claude AI models" -ForegroundColor Gray
Write-Host "  - User project files in source directories" -ForegroundColor Gray
Write-Host "  - Third-party tool icons (pre-commit, etc.)" -ForegroundColor Gray
Write-Host ""
