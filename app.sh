#!/usr/bin/env bash

# create rclone config file
mkdir -p "$HOME/.config/rclone"
echo "$RCLONE_CONF" > "$HOME/.config/rclone/rclone.conf"
# serve sftp backend for google drive
rclone serve sftp --no-auth GoogleDrive: &

while true; do
    # wait for the sftp server to be ready
    if (grep -v "rem_address" /proc/net/tcp|grep ':07E6' 1>/dev/null) || (grep -v "rem_address" /proc/net/tcp6|grep ':07E6' 1>/dev/null); then
      echo "sftp server started!"
      break
    fi
    sleep 3
done

bin/litestream restore -v -if-db-not-exists -if-replica-exists -o data/gotify.db "${DB_REPLICA_URL}"
GOTIFY_SERVER_PORT=$PORT bin/litestream replicate -exec "server" "data/gotify.db" "${DB_REPLICA_URL}"
