{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.yank
      {
        plugin = tmuxPlugins.mkTmuxPlugin {
          pluginName = "tmux-tokyo-night";
          rtpFilePath = "tmux-tokyo-night.tmux";
          version = "156a5a0";
          src = pkgs.fetchFromGitHub {
            owner = "fabioluciano";
            repo = "tmux-tokyo-night";
            rev = "156a5a010928ebae45f0d26c3af172e0425fdda8";
            sha256 = "sha256-tANO0EyXiplXPitLrwfyOEliHUZkCzDJ6nRjEVps180=";
          };
        };
      }
    ];
    keyMode = "vi";
    escapeTime = 10;
    historyLimit = 10000;
    clock24 = true;
    extraConfig = ''
      # ==================
      # {n}vim compability
      set -g default-terminal "tmux-256color"
      set-option -gas terminal-overrides "*:Tc" # true color support
      set-option -gas terminal-overrides "*:RGB" # true color support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0
      # ==================

      # ==================
      # Copy and paste
      bind -T copy-mode-vi 'v' send -X begin-selection
      bind -T copy-mode-vi V send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'wl-copy'
      bind -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "wl-copy"
      # ==================

      # ==================
      # Number windows count from 1, not 0
      set -g base-index 1
      set -g renumber-windows on
      set-option -g focus-events on
      # ==================

      # ==================
      # Hotkeys for switching sessions and selecting projects
      bind -r C-f run-shell -b "PATH=$PATH:/home/$USER/.fzf/bin/ tmux-switch-session"
      bind -r C-s run-shell "PATH=$PATH:/home/$USER/.fzf/bin/ tmux neww tmux-switch-ssh-session"
      bind -r f run-shell "PATH=$PATH:/home/$USER/.fzf/bin/ tmux neww tmux-sessionizer"
      bind K run-shell 'tmux switch-client -n \; kill-session -t "$(tmux display-message -p "#S")" || tmux kill-s'
      bind -r N run-shell "tmux-sessionizer /home/$USER/nixos-config/"
      bind -r O run-shell "tmux-sessionizer /home/$USER/dev/oor/hydromanteia/"
      # ==================

      # Vim-like pane switching
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

      bind c new-window -c "#{pane_current_path}"
      #
      # # POPUP WINDOWS
      # # These two shortcuts provide popup windows in tmux. The lowercase version
      # # makes a popup that named uniquely to the working directory. This is great
      # # for making a popup window in a coding project.
      # #
      # # The uppercase version makes a "global" popup window. Great for persisting
      # # things globally for a long period of time.
      # bind k run-shell '\
      #     POPUP_NAME="popup-$(basename "#{pane_current_path}" | tr -cd "a-zA-Z0-9-")"; \
      #     if [ "#{session_name}" = "$POPUP_NAME" ]; then \
      #         tmux detach-client; \
      #     else \
      #         tmux display-popup -d "#{pane_current_path}" -xC -yC -w 80% -h 75% -E "tmux attach-session -t $POPUP_NAME || tmux new-session -s $POPUP_NAME"; \
      #     fi \
      # '
      #
      # bind K run-shell '\
      #     POPUP_NAME="popup-global"; \
      #     if [ "#{session_name}" = "$POPUP_NAME" ]; then \
      #         tmux detach-client; \
      #     else \
      #         tmux display-popup -xC -yC -w 80% -h 75% -E "tmux attach-session -t $POPUP_NAME || tmux new-session -s $POPUP_NAME"; \
      #     fi \
      # '
    '';
  };
}
