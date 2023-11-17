#!/bin/bash

rm -rf /tmp/* /var/tmp/*
history -c
cat /dev/null > /root/.bash_history
unset HISTFILE

apt-get -y purge droplet-agent
apt-get -y autoremove
apt-get -y autoclean

find /var/log -mtime -1 -type f -exec truncate -s 0 {} \;
rm -rf /var/log/*.gz /var/log/*.[0-9] /var/log/*-???????? /var/log/*.log
rm -rf /var/lib/cloud/instances/*
rm -rf /var/lib/cloud/instance

rm -f /root/.ssh/authorized_keys /etc/ssh/*key*

GREEN='\033[0;32m'
NC='\033[0m'
printf "\n${GREEN}Writing zeros to the remaining disk space to securely
erase the unused portion of the file system.
Depending on your disk size this may take several minutes.
The secure erase will complete successfully when you see:${NC}
    dd: writing to '/zerofile': No space left on device\n
Beginning secure erase now\n"
dd if=/dev/zero of=/zerofile bs=4096; sync; rm /zerofile; sync
cat /dev/null > /var/log/lastlog; cat /dev/null > /var/log/wtmp; cat /dev/null > /var/log/auth.log
