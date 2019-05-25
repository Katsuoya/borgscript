#!/bin/bash

DIR=$(cd "$(dirname $0)" && pwd)
MNTFILE="$DIR/.borg-mntconfig"

export BORG_REPO=$(cat "$DIR/.borg-repo")
export BORG_PASSPHRASE=$(cat "$DIR/.borg-passphrase")

echo $BACKUP_TARGETS

echo "------------------------------------------------------------------------------"
echo "Starting backup on $(date)..."

## Mount drive
if [ -f "$MNTFILE" ]; then
  echo
  echo "Mount backupdrive"

  source "$MNTFILE"

  [ ! -d "$MNTPOINT" ] && { mkdir $MNTPOINT; }
  if ! mountpoint -q $MNTPOINT; then
    echo "Mount $MNTPOINT"
    /bin/mount.nfs $MNTSHARE $MNTPOINT
  fi

  export BORG_REPO="$MNTPOINT/"$(cat "$DIR/.borg-repo")
fi

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
[ -d "/home" ] && { i+=1; FOLDER[$i]="/home"; }
[ -d "/root/dockerdata" ] && { i+=1; FOLDER[$i]="/root/dockerdata"; }
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

## Unmount backupdrive
if [ -f "$MNTFILE" ]; then
  if mountpoint -q $MNTPOINT; then
    echo "Unmount $MNTPOINT"
    /bin/umount $MNTPOINT
  fi
fi

echo
echo "Finished backup on $(date)."
echo "------------------------------------------------------------------------------"
