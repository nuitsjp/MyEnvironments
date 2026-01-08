---
name: issue-starter
description: Creates a worktree for an issue and enters Plan mode to design the implementation. Use when starting work on a GitHub issue, beginning a new task, or tackling a bug fix.
allowed-tools: Bash(gh issue:*), Bash(git checkout:*), Bash(git pull:*), Bash(git branch:*), Bash(git stash:*), Bash(git rev-parse:*), Bash(git show-ref:*), Bash(git worktree:*), Bash(mkdir:*), Bash(cd:*), Bash(pwsh:*), Bash(bash:*), AskUserQuestion, EnterPlanMode, WebSearch, WebFetch, Skill
---

# Issue Starter

## Quick start

Select an issue, create a worktree, and enter Plan mode.

## Repository info

!`git remote -v`

## Current branch

!`git branch --show-current`

## Open issues

!`gh issue list --state open`

## Workflow

Copy this checklist and track progress:

```
- [ ] Step 1: Select issue
- [ ] Step 2: View issue details
- [ ] Step 3: Create worktree
- [ ] Step 4: Move to worktree
- [ ] Step 5: Enter Plan mode
```

### Step 1: Select issue

- If `$1` is provided: Use issue #$1
- Otherwise: Use `AskUserQuestion` to select from open issues

### Step 2: View issue details

Run: `gh issue view {number}`

### Step 3: Create worktree

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

### Step 4: Move to worktree

Run: `cd "{worktreePath}"`

### Step 5: Enter Plan mode

Use `EnterPlanMode` tool to design the implementation based on the issue.

## After implementation

Use `AskUserQuestion` to ask "Create a PR?":
- **Yes**: Use `Skill` tool to invoke `pr-creator`
- **No**: Done
