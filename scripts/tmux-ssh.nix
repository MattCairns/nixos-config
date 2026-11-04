# st <host>: attach to a persistent tmux on the host. mt-copy-id <host>: just install it there.
{pkgs}: let
  remoteShellScript = builtins.readFile ./tmux-ssh-remote.sh;
  mk = name: sshArgs: mode:
    pkgs.writeShellScriptBin name ''
          if [[ $# -ne 1 ]]; then
            printf 'usage: ${name} <ssh-host>\n' >&2
            exit 1
          fi

          exec ${pkgs.openssh}/bin/ssh ${sshArgs} "$1" sh -s -- ${mode} <<'TMUX_SSH_REMOTE'
      ${remoteShellScript}
      TMUX_SSH_REMOTE
    '';
in
  pkgs.symlinkJoin {
    name = "tmux-ssh";
    paths = [
      (mk "st" "-tt" "attach")
      (mk "mt-copy-id" "" "install")
    ];
  }
