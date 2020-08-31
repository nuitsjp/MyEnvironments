# はじめに

Windowsの開発環境を構築・メンテナンスするためのスクリプトなどです。

# 初回実行

```cmd
Start-Process powershell -Verb runAs {Set-ExecutionPolicy RemoteSigned -scope CurrentUser -Force; iwr -useb bit.ly/2PPZh4P | iex; Read-Host}
```

```cmd
git clone https://github.com/nuitsjp/MyEnvironments.git
cd MyEnvironments
install.ps1
```
## License

以下のスクリプトを利用させていただいています。

- local-provisioner by [guitarrapc](https://github.com/guitarrapc/local-provisioner)