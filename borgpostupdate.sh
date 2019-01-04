#!/bin/sh

DIR=$(cd $(dirname $0) && pwd)
echo "Updating permissions..."
chmod 700 "$DIR/borgrun.sh"
chmod 700 "$DIR/borgupdate.sh"
chmod 700 "$DIR/borgbackup.sh"
echo "Permission update done."
