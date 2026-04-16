{pkgs}:
pkgs.writeShellScriptBin "warp" ''
  set -euo pipefail

  LOCATION="$1"
  SOURCE="$(pwd -P)"
  BASENAME="$(basename "$SOURCE")"
  RSYNC_FILTER_ARGS=()

  if [ -f "$SOURCE/.gitignore" ]; then
    RSYNC_FILTER_ARGS+=(--filter='dir-merge,- .gitignore')
  fi

  echo "$BASENAME"

  echo "Warping $SOURCE to $LOCATION"
  ${pkgs.rsync}/bin/rsync -ah --info=progress2 \
    --cvs-exclude \
    "''${RSYNC_FILTER_ARGS[@]}" \
    --exclude "/$BASENAME/.direnv" \
    --exclude "/$BASENAME/build" \
    --exclude "/$BASENAME/target" \
    --exclude "/$BASENAME/result" \
    "$SOURCE" "$LOCATION"
''
