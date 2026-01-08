---
name: pull-request-creator
description: mainブランチからの差分を分析してPull Requestを作成する。Use when the user wants to create a PR (PR作成), merge changes (変更のマージ), or submit code for review (コードレビュー依頼).
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*), Bash(gh pr create:*)
---

# PR Creator

Analyze changes, generate PR title/body, and run `gh pr create`.

## Current branch

!`git branch --show-current`

## Diff from main

!`git diff main`

## Commit history from main

!`git log main..HEAD --oneline`

## Additional resources

- For detailed workflow steps, see [workflow.md](workflow.md)
