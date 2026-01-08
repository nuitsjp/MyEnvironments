---
name: worktree-remover
description: Worktreeを削除し、関連ブランチも削除可能 / Remove worktree and optionally delete branch
agent: agent
---

# Worktree Remover

Worktreeを選択して削除し、オプションで関連ブランチも削除します。

## ワークフロー

### Step 1: Worktreeを選択

引数でworktreeパスが指定されていればそれを使用。
指定がなければ、worktree一覧から選択してもらう。

```bash
git worktree list
```

### Step 2: Worktreeを削除

**Windows (pwsh)**:
```powershell
$branchName = pwsh -File .claude/skills/worktree-remover/scripts/Remove-Worktree.ps1 -WorktreePath "{path}"
```

**Linux/macOS (bash)**:
```bash
branchName=$(bash .claude/skills/worktree-remover/scripts/remove-worktree.sh "{path}")
```

スクリプトの動作:
- worktreeに関連付けられたブランチを取得
- worktreeを削除（`git worktree remove`）
- ブランチ名を返す

### Step 3: ブランチ削除を確認

「ブランチ '{branchName}' を削除しますか？」と確認:
- **Yes**: `git branch -d {branchName}` を実行
- **No**: ブランチを保持
