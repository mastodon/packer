#!/bin/bash

read -p "Would you like to upgrade Mastodon and its dependencies before going live? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$|^$ ]]; then
    echo "Upgrading Debian packages..."
    apt-get update
    apt-get dist-upgrade -yq;

    yarn set version classic

    echo "Downloading new Mastodon code..."
    GIT_TAG=$(su - mastodon -c "cd /home/mastodon/live && git tag -l | grep '^v[0-9.]*$' | sort -V | tail -n 1")
    su - mastodon -c "cd /home/mastodon/live && git fetch --tags && git checkout $GIT_TAG"
    RUBY_VERSION=$(cat /home/mastodon/live/.ruby-version)

    echo "Stopping Mastodon services..."
    systemctl stop mastodon-web
    systemctl stop mastodon-streaming
    systemctl stop mastodon-sidekiq

    echo "Upgrading Ruby..."
    su - mastodon -c "cd /home/mastodon/live && RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION"

    echo "Upgrading Mastodon dependencies..."
    su - mastodon -c "cd /home/mastodon/live && bundle install && yarn install --frozen-lockfile"

    echo "Creating new Mastodon assets and upgrading database..."
    su - mastodon -c "cd /home/mastodon/live && RAILS_ENV=production bundle exec rails assets:clobber assets:precompile db:migrate"

    echo "Restarting Mastodon services..."
    systemctl start mastodon-web
    systemctl start mastodon-streaming
    systemctl start mastodon-sidekiq
fi
