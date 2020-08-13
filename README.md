# はじめに

Windowsの開発環境を構築・メンテナンスするためのスクリプトなどです。

# 初回実行

```cmd
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iwr -useb bit.ly/2PPZh4P | iex
```


# 開発環境をさらしてみる

全部じゃないけどね。だって恥ずかしいじゃん？

[ここ見れば何が入ってるか大体わかります。](https://github.com/nuitsjp/MyEnvironments/blob/master/chocolatery.config)

これも入れると便利だよってのがあればIssuesに記入いただけると嬉しいです。必ずしも入れるという訳にも行きませんが。

なんならPRも一緒に貰えると踊って喜びます。

## 環境の前提条件

- よく利用する開発対象は以下の通り
    - WPF
    - ASP.NET Core
    - .NET Core Console Application
    - .NET Core Windows Service
- Azure・・・は趣味で触る程度
- 基本はChocolateryで入れたい
- でもVisual Studioなど無理がある場合は、別途できるだけCLIで入れたい
# Chocolatreyによるインストール

install-choco.cmdを実行するとChocolateryをインストールし、chocolatery.configに設定しているアプリを一括でインストールします。多分。

CubePDFとCubePDF Utilityはハッシュが違うと怒られるけど、一応忘れないように書いておいてあります。

SSMSが英語で入ってしまうのが悩み。最新でもないし。

メモ

```pwsh
Invoke-WebRequest -Uri https://raw.githubusercontent.com/nuitsjp/MyEnvironments/master/chocolatery.config -OutFile chocolatery.config
choco install chocolatery.config -y
```

## License

以下のスクリプトを利用させていただいています。

- local-provisioner by [guitarrapc](https://github.com/guitarrapc/local-provisioner)