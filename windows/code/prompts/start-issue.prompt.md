---
name: issue-starter
description: Issue作業を開始し、worktreeを作成してPlanモードに入る / Start working on an issue with worktree setup
agent: agent
---

# Issue Starter

Issueを選択し、worktreeを作成して実装計画を立てます。

## ワークフロー

### Step 1: Issueを選択

引数でIssue番号が指定されていればそれを使用。
指定がなければ、オープンなIssue一覧から選択してもらう。

```bash
gh issue list --state open
```

### Step 2: Issue詳細を確認

```bash
gh issue view {number}
```

### Step 3: Worktreeを作成

**Windows (pwsh)**:
```powershell
$worktreePath = pwsh -File .claude/skills/issue-starter/scripts/Setup-Worktree.ps1 -Issue {number}
```

**Linux/macOS (bash)**:
```bash
worktreePath=$(bash .claude/skills/issue-starter/scripts/setup-worktree.sh {number})
```

スクリプトの動作:
- リポジトリルートを取得して移動
- `.worktrees/` ディレクトリを作成（必要な場合）
- `.worktrees/fix-issue-{number}` にworktreeを作成
- worktreeのパスを返す

### Step 4: Worktreeに移動

```bash
cd "{worktreePath}"
```

### Step 5: 実装計画を立てる

Issueの内容に基づいて実装計画を設計する。

## 実装完了後

「PRを作成しますか？」と確認:
- **Yes**: pull-request-creatorを呼び出す
- **No**: 完了
