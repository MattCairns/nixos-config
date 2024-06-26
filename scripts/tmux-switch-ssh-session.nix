{pkgs}:
pkgs.writeShellScriptBin "tmux-switch-ssh-session" ''
  # Define the location of the SSH config file
  ssh_config_file=~/.ssh/config

  # Check if a session name is provided as an argument
  if [[ $# -eq 1 ]]; then
      selected=$1
  else
      # Read a list of SSH hosts from the SSH config file
      hosts=$(${pkgs.gawk}/bin/awk '/^Host / {print $2}' $ssh_config_file)

      # Use fzf to select a host from the list
      selected=$(echo "$hosts" | ${pkgs.fzf}/bin/fzf)
  fi

  # Exit if no host is selected
  if [[ -z $selected ]]; then
      exit 0
  fi

  # Transform the selected host name to a session name
  selected_name=$(echo "$selected" | tr . _)

  # Check if tmux is not already running
  tmux_running=$(pgrep tmux)
  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
      # Start a new tmux session and open an SSH session
      ${pkgs.tmux}/bin/tmux new-session -s $selected_name -c $selected_name "mosh-ssh $selected"
      exit 0
  fi

  # Check if the tmux session with the selected name exists
  if ! ${pkgs.tmux}/bin/tmux has-session -t=$selected_name 2> /dev/null; then
      # Start a new detached tmux session and open an SSH session
      ${pkgs.tmux}/bin/tmux new-session -ds $selected_name -c $selected_name "mosh-ssh $selected"
  fi

  # Switch to the tmux session with the selected name
  ${pkgs.tmux}/bin/tmux switch-client -t $selected_name
''
