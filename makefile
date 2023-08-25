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

# 負荷テスト関係
LOG_FILE = webapp/etc/nginx/access.log
.PHONY: clear-log-file
clear-log-file:
	cp $(LOG_FILE) $(LOG_FILE).`date +%Y%m%d-%H%M%S`
	: > $(LOG_FILE)

.PHONY: load-test
load-test:
	@make --no-print-directory clear-log-file
	ab -c 1 -t 30 http://localhost:80/

.PHONY: analyze-access-log
analyze-access-log:
	tail -n 100 webapp/etc/nginx/access.log | \
		./alp json \
			-o count,method,uri,min,avg,max,sum \
			--sort=sum -r
