s@{ lib, ... }:
lib.mkProfile s "tmux"
{
  programs.tmux = {
    enable = true;
    secureSocket = false;
    keyMode = "vi";
    baseIndex = 1;
    newSession = true;
    historyLimit = 10000;
    terminal = "tmux-256color";
    customPaneNavigationAndResize = true;
    extraConfig = ''
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix
      bind Tab last-window

      bind | split-window -h
      bind - split-window -v

      bind -r C-h select-window -t :-
      bind -r C-l select-window -t :+

      # Change status bar colors
      set -g status-fg white
      set -g status-bg black

      # Change window list colors
      setw -g window-status-style fg=cyan,bg=default,dim
      setw -g window-status-current-style fg=white,bg=red,bright

      # Change pane divider colors
      set -g pane-border-style fg=green,bg=black
      set -g pane-active-border-style fg=white,bg=yellow

      # Customize the command line
      set -g message-style fg=white,bg=black,bright

      # Customize status bar
      set -g status-left-length 40
      set -g status-left "#[fg=green]Session: #S #[fg=yellow]#I #[fg=cyan]#P"
      set -g status-right "#[fg=cyan]%d %b %R"

      # Center the window list
      set -g status-justify centre

      # Identify activity in other windows
      setw -g monitor-activity on
      set -g visual-activity on

      # Remap vi style copy and paste
      unbind [
      bind C-[ copy-mode
      unbind p
      bind p paste-buffer
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
}
