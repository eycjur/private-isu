FROM python:3.10-slim

RUN apt-get update && \
   apt-get install -y default-libmysqlclient-dev build-essential libtcmalloc-minimal4

RUN export LD_PRELOAD="/usr/lib/libtcmalloc_minimal.so.4"
RUN mkdir -p /home/webapp
COPY requirements.freeze /home/webapp
WORKDIR /home/webapp
RUN pip install -r requirements.freeze
COPY . /home/webapp
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--reload", "--log-file", "-", "--access-logfile", "-"]
