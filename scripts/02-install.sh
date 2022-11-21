#!/bin/bash

cd /home/mastodon \
  && git clone https://github.com/rbenv/rbenv.git /home/mastodon/.rbenv \
  && cd /home/mastodon/.rbenv && src/configure && make -C src \
  && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/mastodon/.bashrc \
  && echo 'eval "$(rbenv init -)"' >> /home/mastodon/.bashrc \
  && export PATH="$HOME/.rbenv/bin:$PATH" \
  && eval "$(rbenv init -)" \
  && git clone https://github.com/rbenv/ruby-build.git /home/mastodon/.rbenv/plugins/ruby-build \
  && RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 3.0.3 \
  && rbenv global 3.0.4 \
  && cd /home/mastodon \
  && gem install bundler --no-document \
  && git clone https://github.com/tootsuite/mastodon.git live && cd live \
  && git checkout v4.0.2 \
  && bundle config set --local deployment 'true' \
  && bundle config set --local without 'development test' \
  && bundle install -j$(getconf _NPROCESSORS_ONLN) \
  && yarn install --pure-lockfile \
  && RAILS_ENV=production DB_HOST=/var/run/postgresql SECRET_KEY_BASE=precompile_placeholder OTP_SECRET=precompile_placeholder SAFETY_ASSURED=1 bin/rails db:create db:schema:load assets:precompile
