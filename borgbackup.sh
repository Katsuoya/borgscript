#!/bin/bash

DIR=$(cd "$(dirname $0)" && pwd)
export BORG_REPO=$(cat "$DIR/.borg-repo")
export BORG_PASSPHRASE=$(cat "$DIR/.borg-passphrase")

echo $BACKUP_TARGETS

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
##echo
##echo "Creating database dumps ..."

## Perform Backup
FOLDER[$i]="$DIR"
[ -d "/etc" ] && { i+=1; FOLDER[$i]="/etc"; }
[ -d "/var/lib" ] &&  { i+=1; FOLDER[$i]="/var/lib"; }
[ -d "/var/webmin" ] && { i+=1; FOLDER[$i]="/var/webmin"; }
[ -d "/var/www" ] && { i+=1; FOLDER[$i]="/var/www"; }

echo
echo "Folders to backup:"
for i in ${!FOLDER[@]}; do
  echo "${FOLDER[$i]}"
done

echo
echo "Create backup ..."
borg create -v --stats --compression lzma,6 ::'{hostname}-{now:%Y-%m-%d_%H-%M-%S}' ${FOLDER[@]}
RESULT=$?; if [ ${RESULT} != 0 ]; then
  echo "****************************************************"
  echo " Backup error => exit code: ${RESULT}"
  echo "****************************************************"
  exit 1
fi

exit 0

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
