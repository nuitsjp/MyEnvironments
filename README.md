# はじめに

Windowsの開発環境を構築・メンテナンスするためのスクリプトなどです。

# 事前準備

Userフォルダーを移動したい場合、一番最初につぎの手順を実施します。

- [Windows 10でUsersフォルダを別ドライブへ移動する方法](https://www.nuits.jp/entry/windows10-relocate-users)

# 初回実行

```cmd
Start-Process powershell -Verb runAs {Set-ExecutionPolicy RemoteSigned -scope CurrentUser -Force; iwr -useb https://raw.githubusercontent.com/nuitsjp/MyEnvironments/master/prerequisite.ps1 | iex}
```

完了後、PCを再起動します。

PowerShellからつぎのコマンドを実行します。

```powershell
cd c:\Repos\MyEnvironments
sudo .\update.ps1
```
# 更新

PowerShellからつぎのコマンドを実行します。

```powershell
cd c:\Repos\MyEnvironments
sudo .\update.ps1
```