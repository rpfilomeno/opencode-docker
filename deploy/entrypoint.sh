#!/bin/bash
echo "Start entrypoint.sh"

set -e

# Folder for sshd. No Change.
mkdir -p /var/run/sshd

# Key generation
ls /etc/ssh/ssh_host_* >/dev/null 2>&1 &&echo "Keys is found" ||echo "Key generation." && ssh-keygen -A

# Environment variables that are used if not empty:
# USER_PASSWORD

#Set password
if [ -f /.ispasswordset ]; then
    echo "Password already set"
else
    echo "Set  password of user for sshd"
    echo 'root:'${USER_PASSWORD} |chpasswd
    touch /.ispasswordset
fi

echo "Run sshd"

exec "$@"