#!/bin/sh

DIR=$(cd "$(dirname $0)" && pwd)
export BORG_REPO=$(cat "$DIR/.borg-repo")
#export BORG_PASSCOMMAND=$(cat "$DIR/.borg-passphrase")
export BORG_PASSPHRASE=$(cat "$DIR/.borg-passphrase")

echo "------------------------------------------------------------------------------"
echo "Starting backup on $(date)..."

## Create list of installed software
echo
echo "Create list of installed software ..."
dpkg --get-selections > "$DIR/software.list"
RESULT=$?; if [ ${RESULT} != 0 ]; then
  echo "****************************************************"
  echo " Backup error => exit code: ${RESULT}"
  echo "****************************************************"
  exit 1
fi

## Create database dumps
echo
echo "Creating database dumps ..."
#/bin/bash /root/backup/dbdump.sh

## Perform Backup
echo
echo "Create backup ..."
borg create -v --stats --compression lzma,6 ::'{hostname}-{now:%Y-%m-%d_%H-%M-%S}' \
/home/borgbackup \
/etc \
/var/lib \
/var/webmin \
/var/www
RESULT=$?; if [ ${RESULT} != 0 ]; then
  echo "****************************************************"
  echo " Backup error => exit code: ${RESULT}"
  echo "****************************************************"
  exit 1
fi

## Prune old backups
echo
echo "Prune old backups ..."
borg prune -v --list --keep-daily=7 --keep-weekly=4 --keep-monthly=6
RESULT=$?; if [ ${RESULT} != 0 ]; then
  echo "****************************************************"
  echo " Backup error => exit code: ${RESULT}"
  echo "****************************************************"
  exit 1
fi

## Stats
echo
echo "Repository stats..."
borg info
RESULT=$?; if [ ${RESULT} != 0 ]; then
  echo "****************************************************"
  echo " Backup error => exit code: ${RESULT}"
  echo "****************************************************"
  exit 1
fi

echo
echo "Finished backup on $(date)."
echo "------------------------------------------------------------------------------"
