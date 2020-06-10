FROM python:3.7-slim-buster
LABEL maintainer="pk13055"
LABEL inspired="https://github.com/puckel/docker-airflow/"


ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

ENV AIRFLOW_HOME=/usr/local/airflow
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8
ENV buildDeps=' \
              freetds-dev \
              libkrb5-dev \
              libsasl2-dev \
              libssl-dev \
              libffi-dev \
              libpq-dev \
              git \
              '

# initial build installation
# will be removed later
RUN apt-get update -yqq \
 && apt-get upgrade -yqq \
 && apt-get install -yqq --no-install-recommends $buildDeps \
    freetds-bin \
    build-essential \
    apt-utils \
    curl \
    rsync \
    netcat \ 
    locales

# pip and main packages
RUN sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
 && locale-gen \
 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
 && useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow \
 && pip install -U pip setuptools wheel \
    pip-tools
    pytz \
    pyOpenSSL \
    ndg-httpsclient \
    pyasn1 \
    pyamqp

# airflow specific config
WORKDIR ${AIRFLOW_HOME}
COPY requirements.* .
RUN pip-compile requirements.in > requirements.txt
RUN pip install -U -r requirements.txt

# package installation cleanup
RUN apt-get purge --auto-remove -yqq $buildDeps \
 && apt-get autoremove -yqq --purge \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/* \
           /usr/share/man \
           /usr/share/doc \
           /usr/share/doc-base

WORKDIR ${AIRFLOW_HOME}
COPY --chown=airflow . .
USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["./entrypoint.sh"]
