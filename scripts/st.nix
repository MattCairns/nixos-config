{pkgs}: let
  remoteShellScript = builtins.readFile ./tmux-ssh-remote.sh;
in
  pkgs.writeShellScriptBin "st" ''
            ssh_bin=${pkgs.openssh}/bin/ssh

            if [[ $# -ne 1 ]]; then
              printf 'usage: st <ssh-host>\n' >&2
              exit 1
            fi

        exec "$ssh_bin" -tt "$1" sh -s -- attach <<'TMUX_SSH_REMOTE'
    ${remoteShellScript}
    TMUX_SSH_REMOTE
  ''
