# はじめに

Windowsの開発環境を構築・メンテナンスするためのスクリプトなどです。

# 初回実行

```cmd
Start-Process powershell -Verb runAs {Set-ExecutionPolicy RemoteSigned -scope CurrentUser -Force; iwr -useb https://raw.githubusercontent.com/nuitsjp/MyEnvironments/master/prerequisite.ps1 | iex}
```

完了後、PCを再起動します。

PowerShellからつぎのコマンドを実行します。

```powershell
cd c:\Repos\MyEnvironments
sudo .\Init-Environment.ps1
```
# 更新

PowerShellからつぎのコマンドを実行します。

```powershell
Sync-GistGetPackage
```