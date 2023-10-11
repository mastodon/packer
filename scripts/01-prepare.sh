#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

cloud-init status --wait \
  && apt -qqy update \
  && apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' full-upgrade \
  && apt -qqy install fail2ban iptables-persistent wget gnupg apt-transport-https lsb-release ca-certificates \
  && curl -sS -o - https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /usr/share/keyrings/nodesource.gpg >/dev/null; \
  && curl -sS -o - https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null; \
  && curl -sS -o /usr/share/keyrings/postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc \
  && echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/postgresql.list \
  && apt -qqy update \
  && apt -qqy install imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core \
    g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf \
    bison build-essential libssl-dev libyaml-dev libreadline6-dev \
    zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev \
    nginx redis-server redis-tools postgresql postgresql-contrib \
    certbot python3-certbot-nginx libidn11-dev libicu-dev libjemalloc-dev \
  && corepack enable \
  && yarn set version stable \
  && adduser --disabled-login --gecos '' mastodon \
  && sudo -u postgres psql -c "CREATE USER mastodon CREATEDB;"
