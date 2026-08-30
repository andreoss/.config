{
  config,
  lib,
  ...
}:
{
  config = {
    programs = lib.mkIf config.xsession.enable {
      tmux = {
        enable = true;
        baseIndex = 1;
        keyMode = "vi";
        shortcut = "a";
        escapeTime = 50;
        historyLimit = 1000000;
        mouse = true;
        aggressiveResize = true;
        newSession = true;
        extraConfig = ''

          set-hook -g after-split-window 'selectp -T ""'
          set-hook -g after-new-window 'selectp -T ""'
          set-hook -g after-new-session 'selectp -T ""'

          set-option        -g default-terminal "xterm-256color"
          set-option        -g set-titles on
          set-option        -g set-titles-string "#T / #S / #I #F #W"
          set-window-option -g pane-border-status top
          set-window-option -g pane-border-format '#T'
          set -as terminal-overrides ',tmux*:Ms=\\E]52;%p1%s;%p2%s\\007'
          set -as terminal-overrides ',screen*:Ms=\\E]52;%p1%s;%p2%s\\007'

          set-window-option -g automatic-rename on
          set-option        -g allow-rename on

          set-window-option -g window-status-format         " #I #F #W"
          set-window-option -g window-status-current-format "→#I #F #W"

          set -s set-clipboard on

          set -g status-style        fg=black,bg=darkgray
          set -g status-interval     1
          set -g status-justify      centre
          set -g status-left-length  80
          set -g status-right-length 80

          set -g status-left     '%A#[default] #(hodie)'
          set -g status-right    '#(awk NF=3 /proc/loadavg)'

          set -g pane-active-border-style fg=black,bg=darkgray
        '';
      };
    };
  };
}
