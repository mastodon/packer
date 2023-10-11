#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
NODE_MAJOR_VERSION=20

cloud-init status --wait \
  && apt -qqy update \
  && apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' full-upgrade \
  && apt -qqy install \
    ca-certificates \
    curl \
    fail2ban \
    ffmpeg \
    file \
    g++ \
    gcc \
    git \
    imagemagick \
    iptables-persistent \
    libgdbm-dev \
    libgmp-dev \
    libicu-dev \
    libicu72 \
    libidn-dev \
    libidn12 \
    libjemalloc2 \
    libpq-dev \
    libpq5 \
    libreadline8 \
    libssl-dev \
    libssl3 \
    libyaml-0-2 \
    make \
    patchelf \
    procps \
    shared-mime-info \
    tini \
    tzdata \
    zlib1g-dev \
  && curl -sS -o - https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource.gpg >/dev/null \
  && curl -sS -o - https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
  && curl -sS -o /usr/share/keyrings/postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  && curl -sS -o - https://packages.redis.io/gpg | gpg --dearmor | tee /usr/share/keyrings/redis.gpg >/dev/null \
  && curl -sS -o - https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx.gpg >/dev/null \
  && echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
  && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list \
  && echo "deb [signed-by=/usr/share/keyrings/redis.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list \
  && echo "deb [signed-by=/usr/share/keyrings/nginx.gpg] http://nginx.org/packages/debian/ $(lsb_release -cs) nginx" | tee -a /etc/apt/sources.list.d/nginx.list \
  && apt -qqy update \
  && apt -qqy install \
    certbot \
    nginx \
    nodejs \
    postgresql \
    postgresql-contrib \
    python3-certbot-nginx \
    redis-server \
    redis-tools \
    yarn \
  && corepack enable \
  && yarn set version stable \
  && adduser --disabled-login --gecos '' mastodon \
  && sudo -u postgres psql -c "CREATE USER mastodon CREATEDB;"
