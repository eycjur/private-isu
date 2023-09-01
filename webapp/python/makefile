.PHONY: run-server
run-server:
	gunicorn main:app -b "0.0.0.0:8080" --reload --log-file - --access-logfile -

.PHONY: pip-freeze
pip-freeze:
	pip freeze > requirements.freeze
