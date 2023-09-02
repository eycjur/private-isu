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
LOG_FILE_PYTHON = webapp/logs/python/profile.log
LOG_FILE_PYTHON_WLREPORTER = webapp/logs/python/profile_wlreporter.log
# 負荷テストを実行する
.PHONY: bench
bench:
	# "ログファイルを空にする"
	: > $(LOG_FILE_NGINX)
	: > $(LOG_FILE_MYSQL)
	: > $(LOG_FILE_PYTHON)
	: > $(LOG_FILE_PYTHON_WLREPORTER)

	# "負荷テストを実行する"
	cd benchmarker && docker build -t private-isu-benchmarker .
	cd benchmarker && docker run \
		--rm \
		--network host \
		--name private-isu-benchmarker \
		-i private-isu-benchmarker \
		/opt/go/bin/benchmarker \
			-t http://host.docker.internal \
			-u /opt/go/userdata

## ログ解析関係
# CPUやメモリの使用状況を確認する
.PHONY: stats
stats:
	cd webapp && docker stats

# アクセスログを解析する
.PHONY: analyze-nginx-log
analyze-nginx-log:
	docker build -t alp ./webapp/logs/nginx
	cat $(LOG_FILE_NGINX) | \
		docker run --rm -i alp alp json \
			-o count,method,uri,min,avg,max,sum \
			--sort=sum -r | \
		less

# スロークエリを解析する
.PHONY: analyze-mysql-log
analyze-mysql-log:
	docker pull matsuu/pt-query-digest
	cat $(LOG_FILE_MYSQL) | \
		docker run --rm -i matsuu/pt-query-digest --limit 10 | \
		less

# pythonのprofileを解析する
.PHONY: analyze-python-log
analyze-python-log:
	docker build -t snakeviz ./webapp/logs/python
	docker run --rm -it \
		-v $(shell pwd)/$(LOG_FILE_PYTHON):/tmp/$(LOG_FILE_PYTHON) \
		-p 9111:9111 \
		snakeviz snakeviz -s -H 0.0.0.0 -p 9111 "/tmp/$(LOG_FILE_PYTHON)"

.PHONY: analyze-python-log-wlreporter
analyze-python-log-wlreporter:
	docker build -t wlreporter ./webapp/logs/python \
		-f ./webapp/logs/python/Dockerfile.wlreporter
	docker run --rm -i \
		-v $(shell pwd)/$(shell dirname LOG_FILE_PYTHON_WLREPORTER):/tmp/$(shell dirname LOG_FILE_PYTHON_WLREPORTER) \
		wlreporter wlreporter -f "/tmp/$(LOG_FILE_PYTHON_WLREPORTER)"
	less "$(LOG_FILE_PYTHON_WLREPORTER)_line_data.log"

.PHONY: analyze-python-log-wlreporter-server
analyze-python-log-wlreporter-server:
	open http://0.0.0.0/wsgi_lineprof/

# memcachedの情報を取得
.PHONY: analyze-memcached-stats
analyze-memcached-stats:
	( \
		echo open localhost 11211 && \
		sleep 1 && \
		echo stats && \
		sleep 1 && \
		echo "exit" \
	) | telnet | less

# データベースの中身を確認する
.PHONY: exec-mysql
exec-mysql:
	cd webapp && docker-compose exec mysql bash -c 'mysql -u root -proot isuconp'

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | python3 -u -c 'import sys, re; rx = re.compile(r"^[a-zA-Z0-9\-_]+:"); lines = [line.rstrip() for line in sys.stdin if not line.startswith(".PHONY")]; [print(f"""{line.split(":")[0]:20s}\t{prev.lstrip("# ")}""") if rx.search(line) and prev.startswith("# ") else print(f"""\n\033[92m{prev.lstrip("## ")}\033[0m""") if prev.startswith("## ") else "" for prev, line in zip([""] + lines, lines)]'
