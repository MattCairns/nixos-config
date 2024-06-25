{pkgs}:
pkgs.writeShellScriptBin "mosh-ssh" ''
  ${pkgs.mosh}/bin/mosh "$@"
  [[ $? -ne 0 ]] && (echo; ${pkgs.openssh}/bin/ssh "$@")
''
