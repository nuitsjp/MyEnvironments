# Worktree Remover Workflow

Copy this checklist and track progress:

```
- [ ] Step 1: Select worktree
- [ ] Step 2: Remove worktree
- [ ] Step 3: Confirm branch deletion
```

## Step 1: Select worktree

- If `$1` is provided: Use that worktree path
- Otherwise: Use `AskUserQuestion` to select from worktree list

## Step 2: Remove worktree

**Windows (pwsh)**:
```powershell
$branchName = pwsh -File .claude/skills/worktree-remover/scripts/Remove-Worktree.ps1 -WorktreePath "{path}"
```

**Linux/macOS (bash)**:
```bash
branchName=$(bash .claude/skills/worktree-remover/scripts/remove-worktree.sh "{path}")
```

The script:
- Finds the branch associated with the worktree
- Removes the worktree (`git worktree remove`)
- Returns the branch name

## Step 3: Confirm branch deletion

Use `AskUserQuestion` to ask "Delete branch '{branchName}'?":
- **Yes**: Run `git branch -d {branchName}`
- **No**: Keep the branch
