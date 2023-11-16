#!/bin/bash

cd /home/mastodon \
  && git clone https://github.com/rbenv/rbenv.git /home/mastodon/.rbenv \
  && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/mastodon/.bashrc \
  && echo 'eval "$(/home/mastodon/.rbenv/bin/rbenv init - bash)"' >> /home/mastodon/.bashrc \
  && export PATH="$HOME/.rbenv/bin:$PATH" \
  && eval "$(rbenv init - bash)" \
  && git clone https://github.com/rbenv/ruby-build.git /home/mastodon/.rbenv/plugins/ruby-build \
  && RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 3.2.2 \
  && rbenv global 3.2.2 \
  && cd /home/mastodon \
  && gem install bundler --no-document \
  && git clone https://github.com/mastodon/mastodon.git live && cd live \
  && git checkout v4.2.1 \
  && bundle config set --local deployment 'true' \
  && bundle config set --local without 'development test' \
  && bundle install -j$(getconf _NPROCESSORS_ONLN) \
  && yarn install --pure-lockfile \
  && RAILS_ENV=production DB_HOST=/var/run/postgresql SECRET_KEY_BASE=precompile_placeholder OTP_SECRET=precompile_placeholder SAFETY_ASSURED=1 bin/rails db:create db:schema:load assets:precompile
