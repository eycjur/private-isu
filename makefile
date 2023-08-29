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
	cd webapp && docker-compose down

.PHONY: restart
restart:
	@make --no-print-directory down
	@make --no-print-directory up

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

# アクセスログを解析する
.PHONY: analyze-access-log
analyze-access-log:
	tail -n 100 $(LOG_FILE_NGINX) | \
		./alp json \
			-o count,method,uri,min,avg,max,sum \
			--sort=sum -r

# スロークエリを解析する
.PHONY: analyze-slow-log
analyze-slow-log:
	docker pull matsuu/pt-query-digest
	cat $(LOG_FILE_MYSQL) | \
		docker run --rm -i matsuu/pt-query-digest --limit 10 | \
		less

# CPUやメモリの使用状況を確認する
.PHONY: stats
stats:
	cd webapp && docker stats