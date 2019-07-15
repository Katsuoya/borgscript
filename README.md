# borgscript

Install latest:

1) Create new folder
2) curl -L "https://github.com/sbr1nkmann/borgscript/archive/master.tar.gz" | tar xz --strip-components=1 --overwrite
3) chmod 700 borgrun.sh
4) chmod 700 borgupdate.sh

Install release:

1) Create new folder
2) curl -L "https://github.com/sbr1nkmann/borgscript/tarball/v0.0.9.1" | tar xz --strip-components=1 --overwrite
3) chmod 700 borgrun.sh
4) chmod 700 borgupdate.sh

Required new files to create manuell:

- .github-access -> your GitHub access for limits on request new Version -> USER:PWD or USER:KEY
- .borg-domainname -> your sender email domain name (emails will be send from HOSTNAME@YOURDOMAIN)
- .borg-mailrecipient -> recipient of emmail on success
- .borg-repo -> path to your borg repo
- .borg-passphrase -> passphrase to your borg repo


Add to crontab latest:

- crontab -e 
- 0 0 * * * bash /home/borgbackup/borgrun.sh latest > /dev/null 
- sudo service cron reload

Add to crontab release:

- crontab -e 
- 0 0 * * * bash /home/borgbackup/borgrun.sh > /dev/null 
- sudo service cron reload


Start manuell:

- bash borgrun.sh [latest]
