.PHONY: all
all: restart

## docker関係
.PHONY: up-no-cache
up-no-cache:
	cd webapp && docker-compose build --no-cache
	@make --no-print-directory up

.PHONY: up
up:
	cd webapp && docker-compose up --build

.PHONY: down
down:
	cd webapp && docker-compose down --volumes

.PHONY: restart
restart:
	@make --no-print-directory down
	@make --no-print-directory up

# docker-composeのログを出力する
.PHONY: logs
logs:
	cd webapp && docker-compose logs -f

## 負荷テスト関係
# 負荷テストを実行する
LOG_FILE_NGINX = webapp/etc/nginx/access.log
LOG_FILE_MYSQL = webapp/etc/mysql-slow.log
.PHONY: bench
bench:
	echo "ログファイルを空にする"
	: > $(LOG_FILE_NGINX)
	: > $(LOG_FILE_MYSQL)
	cd benchmarker && docker build -t private-isu-benchmarker .
	cd benchmarker && docker run --network host -i private-isu-benchmarker /opt/go/bin/benchmarker \
		-t http://host.docker.internal \
		-u /opt/go/userdata

## ログ解析関係
# アクセスログを解析する
.PHONY: analyze-access-log
analyze-access-log:
	cat $(LOG_FILE_NGINX) | \
		./alp json \
			-o count,method,uri,min,avg,max,sum \
			--sort=sum -r | \
		less

# スロークエリを解析する
.PHONY: analyze-query-log
analyze-query-log:
	docker pull matsuu/pt-query-digest
	cat $(LOG_FILE_MYSQL) | \
		docker run --rm -i matsuu/pt-query-digest --limit 10 | \
		less

# CPUやメモリの使用状況を確認する
.PHONY: stats
stats:
	cd webapp && docker stats

# データベースの中身を確認する
.PHONY: exec-mysql
exec-mysql:
	cd webapp && docker-compose exec mysql bash -c 'mysql -u root -proot isuconp'
# mysqlコマンド集
# テーブル一覧 SHOW TABLES;
# テーブル構造 SHOW CREATE TABLE <テーブル名>;
# クエリの実行計画 EXPLAIN <クエリ>;
# インデックス作成 ALTER TABLE <テーブル名> ADD INDEX <インデックス名>(<カラム名>);
