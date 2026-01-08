---
name: issue-creator
description: 対話形式でGitHub Issueを作成する。Use when the user wants to create an issue (Issue作成), report a bug (バグ報告), request a feature (機能追加), or improve documentation (ドキュメント改善).
allowed-tools: Bash(git remote:*), Bash(gh issue create:*), AskUserQuestion, Skill
---

# Issue Creator

Select issue type, gather information, and run `gh issue create`.

## Repository info

!`git remote -v`

## Additional resources

- For detailed workflow steps, see [workflow.md](workflow.md)
