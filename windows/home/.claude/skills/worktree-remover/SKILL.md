---
name: worktree-remover
description: Worktreeを削除し、関連ブランチも削除可能。Use when cleaning up after finishing an issue (作業完了後のクリーンアップ), removing unused worktrees (未使用worktree削除), or tidying up the repository (リポジトリ整理).
allowed-tools: Bash(git worktree:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(pwsh:*), Bash(bash:*), AskUserQuestion
---

# Worktree Remover

Select a worktree, remove it, and optionally delete the branch.

## Current worktrees

!`git worktree list`

## Additional resources

- For detailed workflow steps, see [workflow.md](workflow.md)
