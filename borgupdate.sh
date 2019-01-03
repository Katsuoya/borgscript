#!/bin/bash

DIR=$(cd `dirname $0` && pwd)
REPO="Katsuoya/borgscript"
REPOACCESS=`cat $DIR/.github-access`

[[ -z "$REPO" ]] && { echo "Error: No repo specified"; exit 1; }
[[ -z "$REPOACCESS" ]] && { echo "Error: No repokey available"; exit 1; }

LATESTRELEASE=`curl --silent --user $REPOACCESS "https://api.github.com/repos/$REPO/releases/latest" |
  grep '"tag_name":' |
  sed -E 's/.*"([^"]+)".*/\1/'`

[[ -z "$LATESTRELEASE" ]] && { echo "Error: No release found"; exit 1; }
[[ -e "$DIR/.borgversion" ]] && { CURRVERSION=`cat $DIR/.borgversion`; }

echo "Latest release is $LATESTRELEASE"
echo "Local version is $CURRVERSION"
[[ "$LATESTRELEASE" = "$CURRVERSION" ]] && { echo "Latest version already exists"; exit 0; }

echo "Updating borg script..."

curl -L "https://github.com/$REPO/tarball/$LATESTRELEASE" | tar xz --strip-components=1 --overwrite -C $DIR
RESULT=$?; [[ ${RESULT} != 0 ]] && { echo "Error: Download not possible"; exit 1; }

chmod 700 $DIR/borgpostupdate.sh
bash $DIR/borgpostupdate.sh
RESULT=$?; [[ ${RESULT} != 0 ]] && { echo "Error: Postupdate not possible"; exit 1; }

echo $LATESTRELEASE &> $DIR/borgversion
RESULT=$?; [[ ${RESULT} != 0 ]] && { echo "Error: Can not create version file"; exit 1; }

echo "Update done."
