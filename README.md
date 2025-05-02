# README

アプリケーションを起動して動作させるための必要な手順を記載します。

## Ruby のバージョン
このプロジェクトでは Ruby `3.4.3` を使用しています。

## Rails のバージョン
このプロジェクトでは Rails `8.0.2` を使用しています。

## ローカルでの実行方法
- プロジェクトを clone する
```sh
$ git clone git@github.com:Horikawa-Koji/ImageUploader.git
$ cd ImageUploader
```

- データベースを設定する
```sh
$ rails db:create
$ rails db:migrate
```

- ユーザーを作成する
```sh
$ rails runner "User.create!(email_address: 'test@sample.jp', password: 'testabc', password_confirmation: 'testabc')"
```

- Rails サーバを起動する
```sh
$ bin/rails server
```

- 以下のユーザーID、パスワードでログインする
```
ユーザーID:test@sample.jp
パスワード:testabc
```
