mode="${1:-attach}"
socket_name="matthew-tmux"
session_name="main"
config_dir="${HOME}/.local/share/matthew/tmux"
config_path="$config_dir/tmux.conf"
launcher_dir="${HOME}/.local/bin"
launcher_path="$launcher_dir/mt"
shell_bin="${SHELL:-sh}"

write_config() {
  umask 077
  mkdir -p "$config_dir"
  chmod 700 "$config_dir"

  tmp_config="$config_path.tmp.$$"
  printf "%s\n" \
    "setw -g mode-keys vi" \
    "set -g mouse on" \
    "set -g set-clipboard on" \
    "set -sg escape-time 10" \
    "set -g history-limit 10000" \
    "setw -g clock-mode-style 24" \
    "set -g base-index 1" \
    "set -g renumber-windows on" \
    "setw -g aggressive-resize on" \
    "set -g focus-events on" \
    "set -g default-terminal \"tmux-256color\"" \
    "set -as terminal-features \",xterm-256color:RGB,screen-256color:RGB,tmux-256color:RGB\"" \
    "setw -g monitor-activity on" \
    "set -g visual-activity on" \
    "set -g allow-rename off" \
    "setw -g automatic-rename on" \
    "setw -g automatic-rename-format '#{?pane_in_mode,[copy] ,}#{b:pane_current_path}'" \
    "if-shell '[ -f /etc/vessel_uuid ]' \"set -g status-style 'bg=#9EE9ED,fg=black'\"" \
    "set -g status-interval 10" \
    "set -g status-left-length 40" \
    "set -g status-right-length 80" \
    "set -g status-left '#[bold]#H#[default]:#S '" \
    "set -g status-right '#[dim]#(whoami) #[default]#{b:pane_current_path} #([ -f /etc/vessel_uuid ] && [ -s /var/lib/vessel-rejuvenate/artifact_info ] && IFS= read -r version < /var/lib/vessel-rejuvenate/artifact_info; printf %s "\$version" | grep -qi necromanteia || printf %.24s "\$version") %Y-%m-%d %H:%M'" \
    "set -g pane-border-status top" \
    "set -g pane-border-format ' #{pane_index} #{?pane_in_mode,[copy] ,}#{pane_current_command} '" \
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
    "bind -T copy-mode-vi v send -X begin-selection" \
    "bind -T copy-mode-vi r send -X rectangle-toggle" \
    "bind -T copy-mode-vi y send -X copy-selection-and-cancel" \
    "bind c new-window -c \"#{pane_current_path}\"" \
    > "$tmp_config"
  chmod 600 "$tmp_config"

  if [ ! -f "$config_path" ] || ! cmp -s "$tmp_config" "$config_path"; then
    mv "$tmp_config" "$config_path"
  else
    rm -f "$tmp_config"
  fi
}

write_launcher() {
  umask 077
  mkdir -p "$launcher_dir"
  chmod 700 "$launcher_dir"

  tmp_launcher="$launcher_path.tmp.$$"
  cat > "$tmp_launcher" <<'EOF'
#!/bin/sh
config_path="${HOME}/.local/share/matthew/tmux/tmux.conf"
socket_name="matthew-tmux"
session_name="main"

if command -v tmux >/dev/null 2>&1; then
  exec tmux -L "$socket_name" -f "$config_path" new-session -A -s "$session_name"
fi

printf 'tmux is not installed on this host\n' >&2
exit 1
EOF
  chmod 700 "$tmp_launcher"

  if [ ! -f "$launcher_path" ] || ! cmp -s "$tmp_launcher" "$launcher_path"; then
    mv "$tmp_launcher" "$launcher_path"
  else
    rm -f "$tmp_launcher"
  fi
}

reload_if_running() {
  if command -v tmux >/dev/null 2>&1 && tmux -L "$socket_name" list-sessions >/dev/null 2>&1; then
    tmux -L "$socket_name" source-file "$config_path" >/dev/null 2>&1 || true
  fi
}

write_config
write_launcher
reload_if_running

if [ "$mode" = "install" ]; then
  printf 'installed mt at %s\n' "$launcher_path"
  printf 'installed tmux config at %s\n' "$config_path"
  exit 0
fi

if command -v tmux >/dev/null 2>&1; then
  exec tmux -L "$socket_name" -f "$config_path" new-session -A -s "$session_name"
fi

exec "$shell_bin" -l
