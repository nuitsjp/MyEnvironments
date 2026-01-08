# Remove-Worktree.ps1 - Remove a worktree and output its branch name
# Usage: pwsh -File Remove-Worktree.ps1 -WorktreePath <path>
# Output: Prints the branch name associated with the removed worktree

param(
    [Parameter(Mandatory, Position = 0)]
    [string]$WorktreePath
)

$ErrorActionPreference = 'Stop'

# Normalize path
$WorktreePath = $WorktreePath.TrimEnd('/\')

# Get worktree list and find the target
$worktreeList = git worktree list --porcelain
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to get worktree list."
    exit 1
}

# Parse worktree list to find branch
$branchName = $null
$foundWorktree = $false
$currentWorktree = $null

foreach ($line in $worktreeList -split "`n") {
    if ($line -match '^worktree (.+)$') {
        $currentWorktree = $Matches[1].Trim()
    }
    elseif ($line -match '^branch refs/heads/(.+)$' -and $currentWorktree) {
        if ($currentWorktree -eq $WorktreePath -or $currentWorktree -eq (Resolve-Path $WorktreePath -ErrorAction SilentlyContinue)) {
            $branchName = $Matches[1].Trim()
            $foundWorktree = $true
            break
        }
    }
}

if (-not $foundWorktree) {
    # Try with resolved path
    try {
        $resolvedPath = (Resolve-Path $WorktreePath).Path
        foreach ($line in $worktreeList -split "`n") {
            if ($line -match '^worktree (.+)$') {
                $currentWorktree = $Matches[1].Trim()
            }
            elseif ($line -match '^branch refs/heads/(.+)$' -and $currentWorktree) {
                if ($currentWorktree -eq $resolvedPath) {
                    $branchName = $Matches[1].Trim()
                    $foundWorktree = $true
                    break
                }
            }
        }
    }
    catch {
        # Path doesn't exist, continue without resolved path
    }
}

if (-not $foundWorktree) {
    Write-Error "Worktree not found: $WorktreePath"
    exit 1
}

# Remove worktree
git worktree remove $WorktreePath
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to remove worktree: $WorktreePath"
    exit 1
}

# Output branch name for optional deletion
if ($branchName) {
    Write-Output $branchName
}
