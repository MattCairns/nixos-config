{pkgs}: let
  remoteShellScript = builtins.readFile ./tmux-ssh-remote.sh;
in
  pkgs.writeShellScriptBin "mt-copy-id" ''
        ssh_bin=${pkgs.openssh}/bin/ssh

        if [[ $# -ne 1 ]]; then
          printf 'usage: mt-copy-id <ssh-host>\n' >&2
          exit 1
        fi

        exec "$ssh_bin" "$1" sh -s -- install <<'TMUX_SSH_REMOTE'
    ${remoteShellScript}
    TMUX_SSH_REMOTE
  ''
