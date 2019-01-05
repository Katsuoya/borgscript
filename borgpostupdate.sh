#!/bin/bash

DIR=$(cd $(dirname $0) && pwd)
echo "Updating permissions..."
chmod 700 "$DIR/borgrun.sh"
chmod 700 "$DIR/borgupdate.sh"
chmod 700 "$DIR/borgbackup.sh"
chmod 700 "$DIR/borgnotify.sh"
echo "Permission update done."
