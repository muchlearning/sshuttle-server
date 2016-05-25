#!/bin/sh

set -e
echo $AUTHORIZED_KEYS > ~sshuttle/.ssh/authorized_keys
chown sshuttle:sshuttle ~sshuttle/.ssh/authorized_keys
chmod 600 ~sshuttle/.ssh/authorized_keys

KEYS=

for key in /etc/ssh/keys/*key; do
    chmod -f 400 $key
    KEYS="$KEYS -h $key"
done

exec /usr/sbin/sshd -D $KEYS
