#!/bin/sh

echo "------------------------------------------------------------------------------"
echo "borg autoupdater..."
echo

LATEST=0
if [ "$1" != "" ]; then
  [ "$1" = "latest" ] && LATEST=1
  [ $LATEST = 0 ] && { echo "Parameter $1 is not valid"; exit 1; }
fi

DIR=$(cd $(dirname $0) && pwd)
REPO="Katsuoya/borgscript"
REPOACCESS=$(cat "$DIR/.github-access")

[ -z "$REPO" ] && { echo "Error: No repo specified"; exit 1; }
[ -z "$REPOACCESS" ] && { echo "Error: No repokey available"; exit 1; }

if [ $LATEST = 1 ]; then
  LATESTRELEASE="Latest commit"
else
  LATESTRELEASE=$(curl --silent --user "$REPOACCESS" "https://api.github.com/repos/$REPO/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/')
  [ -z "$LATESTRELEASE" ] && { echo "Error: No release found"; exit 1; }
fi

[ -e "$DIR/borgversion" ] && { CURRVERSION=$(cat "$DIR/borgversion"); }

if [ $LATEST = 0 ]; then
  echo "Latest release is $LATESTRELEASE"
  echo "Local version is $CURRVERSION"
  [ "$LATESTRELEASE" = "$CURRVERSION" ] && { echo "Latest version already exists"; echo; exit 0; }
  echo
fi

echo "Current dir is $DIR"
echo
echo "Downloading..."

if [ $LATEST = 1 ]; then
  curl -L "https://github.com/$REPO/archive/master.tar.gz" | tar xz --strip-components=1 --overwrite -C "$DIR"
else
  curl -L "https://github.com/$REPO/tarball/$LATESTRELEASE" | tar xz --strip-components=1 --overwrite -C "$DIR"
fi
RESULT=$?; [ ${RESULT} != 0 ] && { echo "Error: Download not possible"; exit 1; }

echo
chmod 700 "$DIR/borgpostupdate.sh"
"$DIR/borgpostupdate.sh"
RESULT=$?; [ ${RESULT} != 0 ] && { echo "Error: Postupdate not possible"; exit 1; }

echo "$LATESTRELEASE" > "$DIR/borgversion"
RESULT=$?; [ ${RESULT} != 0 ] && { echo "Error: Can not create version file"; exit 1; }

echo
echo "Update done."
echo "------------------------------------------------------------------------------"
