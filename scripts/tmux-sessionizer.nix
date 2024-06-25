{pkgs}:
pkgs.writeShellScriptBin "tmux-sessionizer" ''
  if [[ $# -eq 1 ]]; then
      selected=$1
  else
      selected=$(${pkgs.findutils}/bin/find ~/dev/oor ~/dev/personal  ~/dev/scratch -mindepth 1 -maxdepth 1 -type d | ${pkgs.fzf}/bin/fzf)
  fi

  if [[ -z $selected ]]; then
      exit 0
  fi

  selected_name=$(basename "$selected" | tr . _)
  tmux_running=$(pgrep tmux)

  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
      ${pkgs.tmux}/bin/tmux new-session -s $selected_name -c $selected
      exit 0
  fi

  if ! ${pkgs.tmux}/bin/tmux has-session -t=$selected_name 2> /dev/null; then
      ${pkgs.tmux}/bin/tmux new-session -ds $selected_name -c $selected
  fi

  ${pkgs.tmux}/bin/tmux switch-client -t $selected_name
''
