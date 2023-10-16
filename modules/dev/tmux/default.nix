{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.yank
      tmuxPlugins.resurrect
    ];
    extraConfig = ''
      # set -g default-terminal "tmux-256color"
      # set-option -sa terminal-features ',tmux-256color:RGB'
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"
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

            set -g @resurrect-strategy-nvim 'session'

            # Tokyonight
            set -g mode-style "fg=#7aa2f7,bg=#3b4261"

            set -g message-style "fg=#7aa2f7,bg=#3b4261"
            set -g message-command-style "fg=#7aa2f7,bg=#3b4261"

            set -g pane-border-style "fg=#3b4261"
            set -g pane-active-border-style "fg=#7aa2f7"

            set -g status "on"
            set -g status-justify "left"

            set -g status-style "fg=#7aa2f7,bg=#16161e"

            set -g status-left-length "100"
            set -g status-right-length "100"

            set -g status-left-style NONE
            set -g status-right-style NONE

            set -g status-left "#[fg=#15161e,bg=#7aa2f7,bold] #S #[fg=#7aa2f7,bg=#16161e,nobold,nounderscore,noitalics]"
            set -g status-right "#[fg=#16161e,bg=#16161e,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#16161e] #{prefix_highlight} #[fg=#3b4261,bg=#16161e,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261] %Y-%m-%d  %I:%M %p #[fg=#7aa2f7,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#15161e,bg=#7aa2f7,bold] #h "

            setw -g window-status-activity-style "underscore,fg=#a9b1d6,bg=#16161e"
            setw -g window-status-separator ""
            setw -g window-status-style "NONE,fg=#a9b1d6,bg=#16161e"
            setw -g window-status-format "#[fg=#16161e,bg=#16161e,nobold,nounderscore,noitalics]#[default] #I  #W #F #[fg=#16161e,bg=#16161e,nobold,nounderscore,noitalics]"
            setw -g window-status-current-format "#[fg=#16161e,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261,bold] #I  #W #F #[fg=#3b4261,bg=#16161e,nobold,nounderscore,noitalics]"

      # tmux-plugins/tmux-prefix-highlight support
            set -g @prefix_highlight_output_prefix "#[fg=#e0af68]#[bg=#16161e]#[fg=#16161e]#[bg=#e0af68]"
            set -g @prefix_highlight_output_suffix ""

    '';
  };
}
