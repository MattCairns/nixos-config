{pkgs}:
pkgs.writeShellScriptBin "warp" ''
  LOCATION="$1"
  SOURCE="$(pwd -P)"
  BASENAME="$(basename $(pwd))"
  echo "$BASENAME"

  echo "Warping $SOURCE to $LOCATION"
  ${pkgs.rsync}/bin/rsync -ah --info=progress2 \
    --cvs-exclude \
    --exclude "/$BASENAME/.direnv" \
    --exclude "/$BASENAME/build" \
    --exclude "/$BASENAME/target" \
    --exclude "/$BASENAME/result" \
    $SOURCE $LOCATION
''
