config_dir="${XDG_RUNTIME_DIR:-/tmp/matthew-$(id -u)}"
config_path="$config_dir/tmux-ssh.conf"
socket_name="matthew-ssh"
shell_bin="${SHELL:-sh}"

umask 077
mkdir -p "$config_dir"
chmod 700 "$config_dir"

tmp_config="$config_path.tmp.$$"
printf '%s\n' \
  "setw -g mode-keys vi" \
  "set -sg escape-time 10" \
  "set -g history-limit 10000" \
  "setw -g clock-mode-style 24" \
  "set -g base-index 1" \
  "set -g renumber-windows on" \
  "set -g focus-events on" \
  "bind h select-pane -L" \
  "bind l select-pane -R" \
  "bind k select-pane -U" \
  "bind j select-pane -D" \
  "bind -r C-h select-window -t :-" \
  "bind -r C-l select-window -t :+" \
  "bind -r H resize-pane -L 5" \
  "bind -r J resize-pane -D 5" \
  "bind -r K resize-pane -U 5" \
  "bind -r L resize-pane -R 5" \
  "unbind \\;" \
  "bind \\; split-window -h" \
  "bind -T prefix P switch-client -l" \
  'bind c new-window -c "#{pane_current_path}"' \
  > "$tmp_config"
chmod 600 "$tmp_config"

if [ ! -f "$config_path" ] || ! cmp -s "$tmp_config" "$config_path"; then
  mv "$tmp_config" "$config_path"
else
  rm -f "$tmp_config"
fi

if command -v tmux >/dev/null 2>&1; then
  if tmux -L "$socket_name" list-sessions >/dev/null 2>&1; then
    tmux -L "$socket_name" source-file "$config_path" >/dev/null 2>&1 || true
  fi
  tmux -L "$socket_name" -f "$config_path" new-session -A -s main
fi

"$shell_bin" -l
