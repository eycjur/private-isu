FROM python:3.10-slim

RUN apt-get update && \
   apt-get install -y \
      default-libmysqlclient-dev \
      build-essential \
      libtcmalloc-minimal4

RUN export LD_PRELOAD="/usr/lib/libtcmalloc_minimal.so.4"

RUN mkdir -p /home/webapp
WORKDIR /home/webapp
COPY . /home/webapp
RUN pip install -r requirements.freeze

CMD gunicorn main:app -b "0.0.0.0:8080" --reload --log-file - --access-logfile - -w 8

# # if you want to use newrelic
# ENV NEW_RELIC_CONFIG_FILE=newrelic.ini
# RUN pip install newrelic
# CMD newrelic-admin run-program gunicorn main:app -b "0.0.0.0:8080" --reload --log-file - --access-logfile - -w 8
