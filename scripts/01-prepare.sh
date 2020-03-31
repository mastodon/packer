#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

cloud-init status --wait \
  && apt -qqy update \
  && apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' full-upgrade \
  && apt -qqy install fail2ban iptables-persistent \
  && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt -qqy update \
  && apt -qqy install imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file git-core g++ libprotobuf-dev protobuf-compiler pkg-config nodejs gcc autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev nginx redis-server redis-tools postgresql postgresql-contrib certbot python-certbot-nginx yarn libidn11-dev libicu-dev libjemalloc-dev \
  && adduser --disabled-login --gecos '' mastodon \
  && sudo -u postgres psql -c "CREATE USER mastodon CREATEDB;"
