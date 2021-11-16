#!/bin/bash

cd /home/mastodon \
  && git clone https://github.com/rbenv/rbenv.git /home/mastodon/.rbenv \
  && cd /home/mastodon/.rbenv && src/configure && make -C src \
  && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/mastodon/.bashrc \
  && echo 'eval "$(rbenv init -)"' >> /home/mastodon/.bashrc \
  && export PATH="$HOME/.rbenv/bin:$PATH" \
  && eval "$(rbenv init -)" \
  && git clone https://github.com/rbenv/ruby-build.git /home/mastodon/.rbenv/plugins/ruby-build \
  && RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 2.7.2 \
  && rbenv global 2.7.2 \
  && cd /home/mastodon \
  && gem install bundler --no-document \
  && git clone https://github.com/tootsuite/mastodon.git live && cd live \
  && git checkout v3.4.3 \
  && bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --without development test \
  && yarn install --pure-lockfile \
  && RAILS_ENV=production DB_HOST=/var/run/postgresql SECRET_KEY_BASE=precompile_placeholder OTP_SECRET=precompile_placeholder SAFETY_ASSURED=1 bin/rails db:create db:schema:load assets:precompile
