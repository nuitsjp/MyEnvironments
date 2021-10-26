# はじめに

Windowsの開発環境を構築・メンテナンスするためのスクリプトなどです。

# Usersフォルダーの移動

## 前提条件

ここではDドライブに移動する前提で記述します。

1. 新規インストール直後か、[設定] > [更新とセキュリティ] > [回復]から「このPCを初期状態に戻す」で初期化済みであること
    - 最初はダミーアカウントで初期化すること（後で消します）
2. 以下の内容のファイルを「D:\relocate.xml」に保存する。

[https://raw.githubusercontent.com/nuitsjp/MyEnvironments/master/relocate.xml](https://raw.githubusercontent.com/nuitsjp/MyEnvironments/master/relocate.xml)

## Sysprepを実行する

コマンドプロンプトを管理者モードで開き、次の2つのコマンドを実行する。

```cmd
net stop wmpnetworksvc
%windir%\system32\sysprep\sysprep.exe /oobe /reboot /unattend:d:\relocate.xml
```

再度OSの初期化に入ります。今度は、継続的に利用するアカウントでセットアップする。

あとは最初に作成したダミーアカウントをデータ毎削除すればUsersフォルダーの移動完了。


# 初回実行

```cmd
Start-Process powershell -Verb runAs {Set-ExecutionPolicy RemoteSigned -scope CurrentUser -Force; iwr -useb https://raw.githubusercontent.com/nuitsjp/MyEnvironments/master/prerequisite.ps1 | iex}
```

任意の場所にReposフォルダーを作成し、そこで以下のコマンドをPowerShellから実行する。

```cmd
git clone https://github.com/nuitsjp/MyEnvironments.git
cd MyEnvironments
sudo .\install.ps1
```
