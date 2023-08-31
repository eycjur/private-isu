# private-isu

[Pixiv 社内 ISUCON 2016](https://github.com/catatsuy/private-isu)の内容に、[Python実装](https://github.com/methane/pixiv-isucon2016-python/)を追加し、さらにPython用のDockerfileやログ取得・解析用のスクリプトを追加したものです。

なお、ログ解析用スクリプトは[達人が教えるWebパフォーマンスチューニング〜ISUCONから学ぶ高速化の実践](https://gihyo.jp/book/2022/978-4-297-12846-3)を参考にしています。

## ディレクトリ構成

```
├── ansible_old  # ベンチマーカー・portal用ansible（非推奨）
├── benchmarker  # ベンチマーカーのソースコード
├── portal       # portal（非推奨）
├── provisioning # 競技者用・ベンチマーカーインスタンスセットアップ用ansible
└── webapp       # 各言語の参考実装
```

* [manual.md](/manual.md)は当日マニュアル。一部社内イベントを意識した記述があるので注意すること。
* [public_manual.md](/public_manual.md) は事前公開レギュレーション

## Docker Composeで動かす

### 事前準備

```sh
# MySQLの初期データのダウンロード
cd webapp/sql
curl -L -O https://github.com/catatsuy/private-isu/releases/download/img/dump.sql.bz2
bunzip2 dump.sql.bz2
cd ../..

# ベンチマーカー用の画像をダウンロード
cd benchmarker/userdata
curl -L -O https://github.com/catatsuy/private-isu/releases/download/img/img.zip
unzip img.zip
rm img.zip
cd ../..

# envファイルの作成
cd webapp/python
cp .env.pub .env
```

### アプリの起動

```sh
make up
# http://0.0.0.0:80 からアプリにアクセスできる
```

### ベンチマーカーの実行

アプリ起動後にベンチマーカーを実行できます。

```sh
make bench
# MySQLコンテナの初期データのロードには多少時間がかかるため、コンテナ起動直後は失敗することがあります

# ベンチマーカー実行中にコンテナごとの負荷を確認する
make stats
```

### ログの取得

ベンチマーカーを実行後に解析を行うことができます。

```sh
# アクセスログを解析する
make analyze-access-log
# スロークエリを解析する
make analyze-slow-log
# line-profileを解析する(.envでIS_PROFILE=1にすると有効になる)
make analyze-line-profile
```

### デバッグ

devcontainerを用いたPythonのデバッグが可能です。

1. `make down`でコンテナを停止する  
   デバッグするためには、appのportを解放する必要があります
2. コマンドパレットから`Dev Containers: Reopen in Container`を選択する
3. F5キーでデバッグを開始する
4. 適当なコードにブレークポイントを設定し、ブラウザからアクセスするとブレークポイントで停止する  
   MySQLコンテナの初期データのロードには多少時間がかかります
