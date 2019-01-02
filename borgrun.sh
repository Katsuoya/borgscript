## Mailing
HOSTSHORT=`hostname -s`
MAILSENDER=$HOSTNAME"@"`cat ./.borg-domainname`
MAILRECEIVER=`cat ./.borg-mailrecipient`
HASERROR=0

## Logging
LOG="./backup.log"
exec > >(tee -i ${LOG})
exec 2>&1

[[ $HASERROR = 0 ]] && { ./borgupdate.sh; RESULT=$?; [[ ${RESULT} != 0 ]] && HASERROR=1; }
[[ $HASERROR = 0 ]] && { ./borgbackup.sh; RESULT=$?; [[ ${RESULT} != 0 ]] && HASERROR=1; }

## Log for Httpsrequest
if [ -d "/var/www/html/" ]; then
  WSLOG="/var/www/html/backupstatus.log"
  LOGDATE=`date +%Y-%m-%d`
  LOGTIME=`date +%H-%M-%S`
  [[ $HASERROR = 1 ]] && LOGSTATE="error" || LOGSTATE="success"
  echo "{\"backup\":[{\"date\":\"${LOGDATE}\",\"time\":\"${LOGTIME}\",\"state\":\"${LOGSTATE}\"}]}" &> $WSLOG
fi

## Mail
[[ $HASERROR = 0 ]] && mailx -a "From: "${HOSTSHORT^^}" Backup <"$MAILSENDER">" -s "Backup | Success | "${HOSTSHORT^^} $MAILRECEIVER < $LOG
