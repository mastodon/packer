#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
NODE_MAJOR_VERSION=20

cloud-init status --wait

apt-get update
apt-get dist-upgrade -yq;

apt-get install -y --no-install-recommends \
  autoconf \
  bison \
  build-essential \
  git \
  imagemagick \
  iptables-persistent \
  libffi-dev \
  libgdbm-dev \
  libgmp-dev \
  libicu-dev \
  libidn-dev \
  libjemalloc-dev \
  libncurses5-dev \
  libpq-dev \
  libprotobuf-dev \
  libreadline-dev \
  libssl-dev \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  pkg-config \
  protobuf-compiler \
  shared-mime-info \
  zlib1g-dev

 curl -sS -o - https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource.gpg
 curl -sS -o - https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg
 curl -sS -o - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /usr/share/keyrings/postgresql.gpg
 curl -sS -o - https://packages.redis.io/gpg | gpg --dearmor | tee /usr/share/keyrings/redis.gpg
 curl -sS -o - https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx.gpg
 echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
 echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list
 echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list
 echo "deb [signed-by=/usr/share/keyrings/redis.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list
 echo "deb [signed-by=/usr/share/keyrings/nginx.gpg] http://nginx.org/packages/debian/ $(lsb_release -cs) nginx" | tee -a /etc/apt/sources.list.d/nginx.list

apt-get update
apt-get install -y --no-install-recommends \
  certbot \
  nginx \
  nodejs \
  postgresql \
  postgresql-contrib \
  python3-certbot-nginx \
  redis-server \
  redis-tools \
  yarn

yarn set version classic
adduser --disabled-login --gecos '' mastodon
sudo -u postgres psql -c "CREATE USER mastodon CREATEDB;"