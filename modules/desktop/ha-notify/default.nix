{
  config,
  pkgs,
  ...
}: let
  # Run by ntfy per message. Shows any attached snapshot as a large preview (patched Noctalia, see
  # modules/desktop/noctalia/image-preview.patch), with a "View" action to open it full size.
  show = pkgs.writeShellScript "ha-notify-show" ''
    dir="$XDG_RUNTIME_DIR/ha-notify"
    mkdir -p "$dir"
    find "$dir" -type f -mtime +0 -delete
    url=$(${pkgs.jq}/bin/jq -r '.attachment.url // empty' <<<"$NTFY_RAW")
    img="$dir/$NTFY_ID.jpg"
    if [ -z "$url" ] || ! ${pkgs.curl}/bin/curl -sfo "$img" "$url"; then
      exec ${pkgs.libnotify}/bin/notify-send -u critical -a "Home Assistant" "$NTFY_TITLE" "$NTFY_MESSAGE"
    fi
    # Wait for the action in the background so later messages aren't held up.
    (
      action=$(${pkgs.libnotify}/bin/notify-send -u critical -a "Home Assistant" \
        -h "string:image-path:$img" -c x-noctalia.image-preview -A view=View "$NTFY_TITLE" "$NTFY_MESSAGE")
      [ "$action" = view ] && ${pkgs.xdg-utils}/bin/xdg-open "$img"
    ) &
  '';

  subscribe = pkgs.writeShellScript "ha-notify" ''
    topic=$(cat ${config.sops.secrets.ha-ntfy-topic.path}) && [ -n "$topic" ] || exit 1
    exec ${pkgs.ntfy-sh}/bin/ntfy subscribe "ntfy.sh/$topic" ${show}
  '';
in {
  # Home Assistant camera alerts, pushed via ntfy.sh.
  systemd.user.services.ha-notify = {
    Unit = {
      Description = "Home Assistant desktop notifications";
      Wants = ["sops-nix.service"];
      After = ["graphical-session.target" "sops-nix.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${subscribe}";
      Restart = "always";
      RestartSec = 10;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
