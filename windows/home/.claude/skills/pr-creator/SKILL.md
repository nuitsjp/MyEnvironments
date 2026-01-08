---
name: pr-creator
description: Analyzes diff from main branch and creates a Pull Request. Use when creating a PR, merging changes, or submitting code for review.
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(gh pr create:*)
---

# PR Creator

## Quick start

Analyze changes, generate PR title/body, and run `gh pr create`.

## Current branch

!`git branch --show-current`

## Diff from main

!`git diff main`

## Commit history from main

!`git log main..HEAD --oneline`

## Workflow

Copy this checklist and track progress:

```
- [ ] Step 1: Generate PR title and body
- [ ] Step 2: Check for issue number
- [ ] Step 3: Create PR
- [ ] Step 4: Show result
```

### Step 1: Generate PR title and body

- **Title**: Summarize changes concisely (max 80 chars)
- **Body**:
  - `## Summary`: Purpose and background
  - `## Changes`: Main changes as bullet points
  - `## Testing`: Test method (if applicable)

### Step 2: Check for issue number

If branch name contains `issue` and a number (e.g., `fix-issue-123`):
- Add `Closes #number` at the end of PR body

### Step 3: Create PR

Run: `gh pr create --title "title" --body "body" --base main`

### Step 4: Show result

Display the created PR URL.
