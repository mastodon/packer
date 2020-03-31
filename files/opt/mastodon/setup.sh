#!/bin/bash

echo "Booting Mastodon's first-time setup wizard..." &&
  su - mastodon -c "cd /home/mastodon/live && RAILS_ENV=production /home/mastodon/.rbenv/shims/bundle exec rake digitalocean:setup" &&
  export $(grep '^LOCAL_DOMAIN=' /home/mastodon/live/.env.production | xargs) &&
  cp /home/mastodon/live/dist/nginx.conf /etc/nginx/sites-available/$LOCAL_DOMAIN &&
  sed -i -- "s/example.com/$LOCAL_DOMAIN/g" /etc/nginx/sites-available/$LOCAL_DOMAIN &&
  ln -sfn /etc/nginx/sites-available/$LOCAL_DOMAIN /etc/nginx/sites-enabled/$LOCAL_DOMAIN &&
  systemctl restart nginx &&
  echo "Launching Let's Encrypt utility to obtain SSL certificate..." &&
  certbot certonly --agree-tos --webroot -d $LOCAL_DOMAIN -w /home/mastodon/live/public/ &&
  sed -i -- "s/  # ssl_certificate/  ssl_certificate/" /etc/nginx/sites-available/$LOCAL_DOMAIN &&
  systemctl restart nginx &&
  systemctl enable mastodon-web && systemctl start mastodon-web &&
  systemctl enable mastodon-streaming && systemctl start mastodon-streaming &&
  systemctl enable mastodon-sidekiq && systemctl start mastodon-sidekiq &&
  cp -f /etc/skel/.bashrc /root/.bashrc
