#!/bin/bash

startborg()
{
  VERSION=$1
  HASERROR=0

  [ $HASERROR = 0 ] && { "$DIR/borgupdate.sh" "$VERSION"; RESULT=$?; [ ${RESULT} != 0 ] && HASERROR=1; }
  [ $HASERROR = 0 ] && { "$DIR/borgbackup.sh"; RESULT=$?; [ ${RESULT} != 0 ] && HASERROR=1; }
  [ $HASERROR = 0 ] && { "$DIR/borgnotify.sh" "$HASERROR" "$LOG"; RESULT=$?; [ ${RESULT} != 0 ] && HASERROR=1; }
  [ $HASERROR = 1 ] && { echo "Error occured"; exit 1; }
}

####
## MAIN
####
DIR=$(cd $(dirname $0) && pwd)
LOG="$DIR/backup.log"

echo "------------------------------------------------------------------------------"
echo "Starting borg..."
echo "Logging to $LOG"
echo

startborg "$1" 2>&1 | tee "$LOG"

echo
echo "Borg finished."
echo "------------------------------------------------------------------------------"

exit 0
