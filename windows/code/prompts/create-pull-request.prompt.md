---
name: pull-request-creator
description: mainブランチからの差分を分析してPull Requestを作成する / Create PR by analyzing diff from main
agent: agent
---

# PR Creator

変更内容を分析し、PRタイトルと本文を生成してPull Requestを作成します。

## ワークフロー

### Step 1: PRタイトルと本文を生成

まず現在の状態を確認:

```bash
git branch --show-current
git diff main
git log main..HEAD --oneline
```

生成ルール:
- **タイトル**: 変更を簡潔に要約（最大80文字）
- **本文**:
  - `## Summary`: 目的と背景
  - `## Changes`: 主な変更点（箇条書き）
  - `## Testing`: テスト方法（該当する場合）

### Step 2: Issue番号を確認

ブランチ名に `issue` と番号が含まれている場合（例: `fix-issue-123`）:
- PR本文の末尾に `Closes #番号` を追加

### Step 3: PRを作成

```bash
gh pr create --title "title" --body "body" --base main
```

### Step 4: 結果を表示

作成されたPRのURLを表示する。
