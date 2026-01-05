# lazy.d - 遅延ロード設定（将来用）

このディレクトリは、起動時の遅延ロード用スクリプトを配置する場所です。

## 現在の状態

**現時点では未使用です。**  
将来、起動時間が問題になった場合に利用します。

## 使用例（将来）

`Register-EngineEvent PowerShell.OnIdle` を使った遅延ロード:

```powershell
# profile.d/00-env.ps1 等から呼び出す想定
Register-EngineEvent PowerShell.OnIdle -Action {
    Unregister-Event -SourceIdentifier $event.SourceIdentifier
    . "$env:USERPROFILE\src\pwsh-profile\lazy.d\posh-git.ps1"
}
```

## 配置するスクリプト候補

- 重い PowerShell モジュールの Import
- 外部 CLI ツールの初期化
- プロンプトカスタマイズ（Starship / Oh My Posh 等）
- Git 統合（posh-git 等）

## 原則

- 起動直後に不要なものだけを配置
- OnIdle で確実に実行される前提で設計
- profile.d で読み込む設定とは明確に分離
