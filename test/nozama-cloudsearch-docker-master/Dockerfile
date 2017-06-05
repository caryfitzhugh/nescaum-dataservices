FROM ubuntu:14.04

MAINTAINER Mike du Heaume <mduheaume@strathcom.com>

RUN apt-get update && DEBIAN_FRONTEND='noninteractive' apt-get install -y \
        git-core \
        python-dev \
        python-pip \
    && rm -rf /var/lib/apt/lists/*

ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt

ADD config.ini config.ini

EXPOSE 5000

CMD ["pserve", "config.ini"]
