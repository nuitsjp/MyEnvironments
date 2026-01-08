# Issue Starter Workflow

Copy this checklist and track progress:

```
- [ ] Step 1: Select issue
- [ ] Step 2: View issue details
- [ ] Step 3: Create worktree
- [ ] Step 4: Move to worktree
- [ ] Step 5: Enter Plan mode
```

## Step 1: Select issue

- If `$1` is provided: Use issue #$1
- Otherwise: Use `AskUserQuestion` to select from open issues

## Step 2: View issue details

Run: `gh issue view {number}`

## Step 3: Create worktree

**Windows (pwsh)**:
```powershell
$worktreePath = pwsh -File .claude/skills/issue-starter/scripts/Setup-Worktree.ps1 -Issue {number}
```

**Linux/macOS (bash)**:
```bash
worktreePath=$(bash .claude/skills/issue-starter/scripts/setup-worktree.sh {number})
```

The script:
- Gets repository root and moves there
- Creates `.worktrees/` directory if needed
- Creates worktree at `.worktrees/fix-issue-{number}`
- Returns the worktree path

## Step 4: Move to worktree

Run: `cd "{worktreePath}"`

## Step 5: Enter Plan mode

Use `EnterPlanMode` tool to design the implementation based on the issue.

## After implementation

Use `AskUserQuestion` to ask "Create a PR?":
- **Yes**: Use `Skill` tool to invoke `pr-creator`
- **No**: Done
