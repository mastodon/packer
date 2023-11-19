#!/bin/bash

read -p "Would you like to upgrade Mastodon and its dependencies before going live? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$|^$ ]]; then
    echo "Upgrading Debian packages..."
    apt-get update
    apt-get dist-upgrade -yq;

    yarn set version classic

    echo "Downloading new Mastodon code..."
    su - mastodon -c "cd /home/mastodon/live && git fetch --tags && git checkout $(su - mastodon -c 'cd /home/mastodon/live && git tag -l | grep '^v[0-9.]*$' | sort -V | tail -n 1')"
    RUBY_VERSION=$(cat /home/mastodon/live/.ruby-version)

    echo "Stopping Mastodon services..."
    systemctl stop mastodon-web
    systemctl stop mastodon-streaming
    systemctl stop mastodon-sidekiq

    echo "Upgrading Ruby..."
    su - mastodon -c "cd /home/mastodon/live && RUBY_CONFIGURE_OPTS=--with-jemalloc /home/mastodon/.rbenv/bin/rbenv install $RUBY_VERSION && /home/mastodon/.rbenv/bin/rbenv global $RUBY_VERSION"

    echo "Upgrading Mastodon dependencies..."
    su - mastodon -c "cd /home/mastodon/live && /home/mastodon/.rbenv/shims/bundle install && yarn install --frozen-lockfile"

    echo "Creating new Mastodon assets and upgrading database..."
    su - mastodon -c "cd /home/mastodon/live && RAILS_ENV=production /home/mastodon/.rbenv/shims/bundle exec rails assets:clobber assets:precompile db:migrate"

    echo "Restarting Mastodon services..."
    systemctl start mastodon-web
    systemctl start mastodon-streaming
    systemctl start mastodon-sidekiq
fi
