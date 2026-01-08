---
name: issue-starter
description: Issue作業を開始し、ブランチを作成してPlanモードに入る。Use when the user wants to start working on an issue (Issue対応開始), begin a task (タスク開始), or tackle a GitHub issue (課題着手).
allowed-tools: Bash(gh issue:*), Bash(git checkout:*), Bash(git pull:*), Bash(git branch:*), Bash(git stash:*), Bash(git rev-parse:*), Bash(git show-ref:*), Bash(git worktree:*), Bash(mkdir:*), Bash(cd:*), Bash(pwsh:*), Bash(bash:*), AskUserQuestion, EnterPlanMode, WebSearch, WebFetch, Skill
---

# Issue Starter

Select an issue, create a worktree, and enter Plan mode.

## Repository info

!`git remote -v`

## Current branch

!`git branch --show-current`

## Open issues

!`gh issue list --state open`

## Additional resources

- For detailed workflow steps, see [workflow.md](workflow.md)
