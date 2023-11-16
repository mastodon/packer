#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

NODE_MAJOR=20

cloud-init status --wait \
  && apt-get -qqy update \
  && apt-get -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' full-upgrade \
  && apt-get -qqy install fail2ban iptables-persistent wget curl gnupg apt-transport-https lsb-release ca-certificates \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list \
  && wget -O /usr/share/keyrings/postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  && echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list \
  && apt-get -qqy update \
  && apt-get -qqy install imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
    g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
    bison build-essential libssl-dev libyaml-dev libreadline6-dev \
    zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
    nginx redis-server redis-tools postgresql postgresql-contrib \
    certbot python3-certbot-nginx libidn11-dev libicu-dev libjemalloc-dev \
    nodejs \
  && corepack enable \
  && yarn set version stable \
  && adduser --disabled-login --gecos '' mastodon \
  && sudo -u postgres psql -c "CREATE USER mastodon CREATEDB;"
