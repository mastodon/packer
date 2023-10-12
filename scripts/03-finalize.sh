#!/bin/bash

systemctl restart fail2ban
iptables-restore < /etc/iptables/rules.v4
cp /home/mastodon/live/dist/*.service /etc/systemd/system/

chmod +x /opt/mastodon/setup.sh
chmod +x /opt/upgrade-mastodon.sh

cp -f /etc/skel/.bashrc /root/.bashrc
echo '/opt/mastodon/setup.sh' >> /root/.bashrc