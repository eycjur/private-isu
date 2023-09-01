.PHONY: default
default: help

## docker関係
# docker-composeでコンテナを起動する
.PHONY: up
up:
	cd webapp && docker-compose up --build

# docker-composeでコンテナを停止する
.PHONY: down
down:
	cd webapp && docker-compose down

# docker-composeでコンテナを停止し、まっさらな状態にする
.PHONY: down-all
down-all:
	cd webapp && docker-compose down --rmi all --volumes --remove-orphans

# docker-composeでコンテナを再起動する
.PHONY: restart
restart:
	@make --no-print-directory down
	@make --no-print-directory up

# docker-composeのログを出力する
.PHONY: logs
logs:
	cd webapp && docker-compose logs -f

## 負荷テスト関係
LOG_FILE_NGINX = webapp/logs/nginx/access.log
LOG_FILE_MYSQL = webapp/logs/mysql/mysql-slow.log
LOG_FILE_LINE_PROFILE = webapp/logs/python/profile.log
LOG_FILE_NAME_LINE_PROFILE = $(shell basename $(LOG_FILE_LINE_PROFILE))
# 負荷テストを実行する
.PHONY: bench
bench:
	echo "ログファイルを空にする"
	: > $(LOG_FILE_NGINX)
	: > $(LOG_FILE_MYSQL)
	: > $(LOG_FILE_LINE_PROFILE)
	cd benchmarker && docker build -t private-isu-benchmarker .
	cd benchmarker && docker run --network host -i private-isu-benchmarker /opt/go/bin/benchmarker \
		-t http://host.docker.internal \
		-u /opt/go/userdata

## ログ解析関係
# CPUやメモリの使用状況を確認する
.PHONY: stats
stats:
	cd webapp && docker stats

# アクセスログを解析する
.PHONY: analyze-access-log
analyze-access-log:
	docker build -t alp ./webapp/logs/nginx
	cat $(LOG_FILE_NGINX) | \
		docker run --rm -i alp alp json \
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

# line-profileを解析する
.PHONY: analyze-line-profile
analyze-line-profile:
	docker build -t wlreporter ./webapp/logs/python
	docker run --rm -i \
		-v $(PWD)/webapp/logs/python:/tmp \
		wlreporter wlreporter -f "/tmp/$(LOG_FILE_NAME_LINE_PROFILE)"
	less "webapp/logs/python/$(LOG_FILE_NAME_LINE_PROFILE)_line_data.log"

.PHONY: analyze-line-profile-server
analyze-line-profile-server:
	open http://0.0.0.0/wsgi_lineprof/

# データベースの中身を確認する
.PHONY: exec-mysql
exec-mysql:
	cd webapp && docker-compose exec mysql bash -c 'mysql -u root -proot isuconp'
# mysqlコマンド集
# テーブル一覧 SHOW TABLES;
# テーブル構造 SHOW CREATE TABLE <テーブル名>;
# クエリの実行計画 EXPLAIN <クエリ>;
# インデックス作成 ALTER TABLE <テーブル名> ADD INDEX <インデックス名>(<カラム名>);

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | python3 -u -c 'import sys, re; rx = re.compile(r"^[a-zA-Z0-9\-_]+:"); lines = [line.rstrip() for line in sys.stdin if not line.startswith(".PHONY")]; [print(f"""{line.split(":")[0]:20s}\t{prev.lstrip("# ")}""") if rx.search(line) and prev.startswith("# ") else print(f"""\n\033[92m{prev.lstrip("## ")}\033[0m""") if prev.startswith("## ") else "" for prev, line in zip([""] + lines, lines)]'
