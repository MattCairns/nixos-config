{pkgs}:
pkgs.writeShellScriptBin "tmux-windowizer" ''
  branch_name=$(basename $1)
  session_name=$(${pkgs.tmux}/bin/tmux display-message -p "#S")
  clean_name=$(echo $branch_name | tr "./" "__")
  target="$session_name:$clean_name"

  if ! ${pkgs.tmux}/bin/tmux has-session -t $target 2> /dev/null; then
      ${pkgs.tmux}/bin/tmux neww -dn $clean_name
  fi

  shift
  ${pkgs.tmux}/bin/tmux send-keys -t $target "$*"
''
