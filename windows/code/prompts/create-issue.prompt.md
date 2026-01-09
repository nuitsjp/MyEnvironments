---
name: issue-creator
description: 対話形式でGitHub Issueを作成する / Create GitHub Issues interactively
agent: agent
---

# Issue Creator

対話形式でGitHub Issueを作成します。

## ワークフロー

### Step 1: Issueタイプを選択

ユーザーに以下から選択してもらう:
- **bug**: バグ報告（エラー、予期しない動作）
- **enhancement**: 機能リクエスト（新機能、改善）
- **documentation**: ドキュメント（誤字、情報不足）
- **question**: 質問（使い方、設計）

### Step 2: 情報を収集

タイプに応じて必要な情報を収集:

| タイプ | 必要な情報 |
|--------|------------|
| bug | タイトル、再現手順、期待値 vs 実際の動作 |
| enhancement | タイトル、目的、提案する解決策 |
| documentation | タイトル、対象ページ、現状の問題、改善案 |
| question | タイトル、詳細、コンテキスト |

### Step 3: Issueを作成

```bash
gh issue create --title "title" --body "body" --label "type"
```

作成されたIssueのURLを表示する。

### Step 4: 次のアクションを提案

「このIssueの作業を開始しますか？」と確認:
- **Yes**: issue-starterを呼び出す
- **No**: 完了
