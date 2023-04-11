{ config
, pkgs
, user
, ...
}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.power-theme
    ];
    extraConfig = ''
      set -g default-terminal "screen-256color"
      set-window-option -g mode-keys vi
      bind -T copy-mode-vi 'v' send -X begin-selection
      bind -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "xclip -i -selection clipboard"
      set -g base-index 1
      set -g renumber-windows on
      set-option -sg escape-time 10
      set-option -g focus-events on

      bind c new-window -c "#{pane_current_path}"

      bind -r C-f run-shell -b "PATH=$PATH:/home/$USER/.fzf/bin/ /home/$USER/.config/bin/tmux-switch-session"
      bind -r f run-shell "PATH=$PATH:/home/$USER/.fzf/bin/ tmux neww /home/$USER/.config/bin/tmux-sessionizer"
      bind K run-shell 'tmux switch-client -n \; kill-session -t "$(tmux display-message -p "#S")" || tmux kill-s'

      # Projects
      bind -r N run-shell "/home/$USER/.config/bin/tmux-sessionizer /home/$USER/nixos-config/"

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

      unbind \;
      bind \; split-window -h

      bind -T prefix P switch-client -l

    '';
  };
}
