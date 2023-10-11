#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
NODE_MAJOR_VERSION=20

cloud-init status --wait

apt-get update
apt-get install -y \
  autoconf \
  bison \
  build-essential \
  certbot \
  curl \
  file \
  g++ \
  gcc \
  git \
  git-core \
  imagemagick \
  iptables-persistent \
  libffi-dev \
  libgdbm-dev \
  libgmp-dev \
  libicu-dev \
  libicu72 \
  libidn-dev \
  libidn12 \
  libjemalloc2-dev \
  libncurses5-dev \
  libpq-dev \
  libpq5 \
  libprotobuf-dev \
  libreadline6-dev \
  libreadline8 \
  libssl-dev \
  libssl3 \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  make \
  nodejs \
  patchelf \
  pkg-config \
  protobuf-compiler \
  procps \
  shared-mime-info \
  tini \
  tzdata \
  zlib1g-dev

curl -sS https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | apt-key add -
echo "deb https://deb.nodesource.com/node_${NODE_MAJOR_VERSION}.x $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/nodesource.list

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/postgresql.list

curl -sS https://packages.redis.io/gpg | apt-key add -
echo "deb https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list

curl -sS https://nginx.org/keys/nginx_signing.key | apt-key add -
echo "deb http://nginx.org/packages/debian/ $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list

apt-get update
apt-get install -y \
  nginx \
  nodejs \
  postgresql \
  postgresql-contrib \
  python3-certbot-nginx \
  redis-server \
  redis-tools \
  yarn

# corepack enable
yarn set version classic
adduser --disabled-login --gecos '' mastodon
sudo -u postgres psql -c "CREATE USER mastodon CREATEDB;"