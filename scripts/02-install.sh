#!/bin/bash

cd /home/mastodon \
  && git clone https://github.com/mastodon/mastodon.git /home/mastodon/live \
  && cd /home/mastodon/live \
  && git checkout $(git tag -l | grep '^v[0-9.]*$' | sort -V | tail -n 1) \
  && cd .. \
  && git clone https://github.com/rbenv/rbenv.git /home/mastodon/.rbenv \
  && echo 'export PATH="$/home/mastodon/.rbenv/bin:$PATH"' >> /home/mastodon/.bashrc \
  && echo 'export PATH="/home/mastodon/.rbenv/plugins/ruby-build/bin:$PATH"' >> /home/mastodon/.bashrc \
  && echo 'eval "$(rbenv init -)"' >> /home/mastodon/.bashrc \
  && export PATH="/home/mastodon/.rbenv/bin:$PATH" \
  && export PATH="/home/mastodon/.rbenv/plugins/ruby-build/bin:$PATH" \
  && eval "$(rbenv init -)" \
  && git clone https://github.com/rbenv/ruby-build.git /home/mastodon/.rbenv/plugins/ruby-build \
  && RUBY_VERSION=$(cat /home/mastodon/live/.ruby-version) \
  && RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install $RUBY_VERSION \
  && rbenv global $RUBY_VERSION \
  && cd /home/mastodon/live \
  && gem install bundler --no-document \
  && git clone https://github.com/tootsuite/mastodon.git live && cd live \
  && bundle config set --local deployment 'true' \
  && bundle config set --local without 'development test' \
  && bundle install -j$(getconf _NPROCESSORS_ONLN) \
  && yarn install --pure-lockfile \
  && RAILS_ENV=production DB_HOST=/var/run/postgresql SECRET_KEY_BASE=precompile_placeholder OTP_SECRET=precompile_placeholder SAFETY_ASSURED=1 bin/rails db:create db:schema:load assets:precompile
