{
  config,
  pkgs,
  user,
  ...
}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.power-theme
    ];
    extraConfig = ''
            set -g default-terminal "screen-256color"
            set-window-option -g mode-keys vi
            set -g base-index 1
            set -g renumber-windows on
            set-option -sg escape-time 10
            set-option -g focus-events on

            bind c new-window -c "#{pane_current_path}"

            bind-key -r C-f run-shell -b "PATH=$PATH:/home/$USER/.fzf/bin/ /home/$USER/.config/bin/tmux-switch-session"
            bind-key -r f run-shell "PATH=$PATH:/home/$USER/.fzf/bin/ tmux neww /home/$USER/.config/bin/tmux-sessionizer"
            bind-key K run-shell 'tmux switch-client -n \; kill-session -t "$(tmux display-message -p "#S")" || tmux kill-s'

      # Projects
            bind-key -r N run-shell "/home/$USER/.config/bin/tmux-sessionizer /home/$USER/nixos-config/"
            bind-key -r J run-shell "/home/$USER/.config/bin/tmux-sessionizer /home/$USER/dev/oor/core/subsystems/ipc/"
            bind-key -r T run-shell "/home/$USER/.config/bin/tmux-sessionizer /home/$USER/dev/oor/ && tmux send-keys -t oor 'sure testbed' C-m"

            bind h select-pane -L
            bind l select-pane -R
            bind k select-pane -U
            bind j select-pane -D

            bind -r C-h select-window -t :-
            bind -r C-l select-window -t :+

            bind -r H resize-pane -L 5
            bind -r J resize-pane -D 5
            bind -r K resize-pane -U 5
            bind -r L resize-pane -R 5

            bind-key -T prefix P switch-client -l

            bind ; split-window -h -c "#{pane_current_path}"
    '';
  };
}
