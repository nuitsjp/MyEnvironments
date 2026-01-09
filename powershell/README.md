# PowerShell Profile Repository

PowerShell / Codex CLI / Claude Code / GitHub Copilot を横断して長期運用する人向けの profile 構成です。

## 構成

```
powershell/
├─ profile.d/          # 即時ロード設定
│  ├─ 00-env.ps1       # 環境変数・共通フラグ
│  ├─ 10-alias.ps1     # alias 定義
│  ├─ 20-functions.ps1 # 軽量関数
│  ├─ 30-tools.ps1     # CLI ツール補助
│  ├─ 90-local.ps1     # ローカル専用（Git 管理外）
│  └─ README.md
├─ lazy.d/             # 将来用（OnIdle / 遅延ロード）
│  └─ README.md
├─ .gitignore
└─ README.md
```

## セットアップ

### 1. リポジトリをクローン

```powershell
cd $env:USERPROFILE\src
git clone <your-repo-url> pwsh-profile
```

### 2. Microsoft.PowerShell_profile.ps1 を設定

`$PROFILE` (通常 `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`) に以下を記述:

```powershell
$ProfileDir  = Join-Path 'D:' 'MyEnvironments' 'powershell' 'profile.d'

Write-Output "Loading profile: $ProfileDir"
if (Test-Path $ProfileDir) {
    Get-ChildItem $ProfileDir -Filter *.ps1 |
        Sort-Object Name |
        ForEach-Object {
            try {
                . $_.FullName
            } catch {
                Write-Warning "profile load failed: $($_.Name)"
            }
        }
}
```

### 3. PowerShell を再起動

```powershell
. $PROFILE
```

## 設計思想

- **profile = ブートローダー専用** - 実体は Git 管理リポジトリ
- **profile.d/ = 即時ロード** - 起動時に毎回読み込まれる軽量設定
- **lazy.d/ = 将来用** - OnIdle で遅延ロード（現時点では未使用）
- **やらないことを決めた構成** - 必要になるまでモジュール化・最適化しない

## 運用ルール

### ✅ やること

- profile 本体は触らない
- 追加は**必ず `profile.d`**
- ファイルは「軽く・短く」

### ❌ やらないこと

- 巨大 `.ps1` を 1 枚に集約しない
- Import-Module をむやみに増やさない
- 起動時に重い処理を入れない

## 将来の拡張ステップ

1. `lazy.d` を使い始める
2. 重くなったら OnIdle 化
3. 再利用したくなったらモジュール化
4. CI / Pester で検証
5. 社内・OSS 公開

## ライセンス

MIT License
