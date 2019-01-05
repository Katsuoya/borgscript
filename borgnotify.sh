#!/bin/bash

HOSTSHORT=$(hostname -s)
MAILSENDER=$HOSTSHORT"@"$(cat "$DIR/.borg-domainname")
MAILRECEIVER=$(cat "$DIR/.borg-mailrecipient")
HASERROR=$1
LOG=$2

## Log for Httpsrequest
if [ -d "/var/www/html/" ]; then
  WSLOG="/var/www/html/backupstatus.log"
  LOGDATE=$(date +%Y-%m-%d)
  LOGTIME=$(date +%H-%M-%S)
  [ $HASERROR = 1 ] && LOGSTATE="error" || LOGSTATE="success"
  echo "{\"backup\":{\"date\":\"${LOGDATE}\",\"time\":\"${LOGTIME}\",\"state\":\"${LOGSTATE}\"}}" > $WSLOG
fi

## Mail
[ $HASERROR = 0 ] && mailx -a "From: ${HOSTSHORT} Backup <$MAILSENDER>" -s "Backup | Success | ${HOSTSHORT}" $MAILRECEIVER < "$LOG"
