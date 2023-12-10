{ config, pkgs, lib, inputs, ... }:
let palette = import ../os/palette.nix;
in {
  config = {
    xresources.properties = with palette;
      lib.mkIf config.xsession.enable {
        "XTerm*charClass" = [ "37:48" "45-47:48" "58:48" "64:48" "126:48" ];
        "*background" = black2;
        "*color0" = black1;
        "*color1" = red1;
        "*color2" = green2;
        "*color3" = yellow1;
        "*color4" = blue1;
        "*color5" = magenta;
        "*color6" = cyan1;
        "*color7" = white1;
        "*color8" = gray2;
        "*color9" = red2;
        "*color10" = green3;
        "*color11" = yellow2;
        "*color12" = blue5;
        "*color13" = cyan2;
        "*color14" = green2;
        "*color15" = white2;
        "*foreground" = white3;
      };
    home.packages = with pkgs; [ antiword ];
    home.file = {
      ".config/procps/toprc".source = ./../toprc;
      ".urxvt/ext/context".text =
        builtins.readFile "${inputs.urxvt-context-ext}/context";
      ".local/bin/rxvt" = {
        executable = true;
        text = ''
          #!/bin/sh
          exec urxvtc "$@"
        '';
      };
    };
    systemd.user.services = lib.mkIf config.xsession.enable {
      urxvtd = {
        Unit = {
          Description = "Urxvtd";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.rxvt-unicode}/bin/urxvtd --quiet --opendisplay";
          Restart = "always";
          RestartSec = "3";
        };
        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    };
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

          set-option -g default-terminal "xterm-256color"
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
      urxvt = {
        enable = true;
        package = pkgs.rxvt-unicode-unwrapped;
        iso14755 = true;
        fonts = [ "xft:Terminus:size=12" ];
        scroll = {
          bar = {
            enable = true;
            style = "plain";
          };
          lines = 10000000;
          scrollOnOutput = false;
          scrollOnKeystroke = true;
        };
        extraConfig = with palette; {
          "context.names" = "sudo,ssh,python,gdb,java,vi";
          "context.sudo.background" = "[90]${red4}";
          "context.ssh.background " = "[90]${blue6}";
          "context.python.background" = "[90]${blue6}";
          "context.gdb.background" = "[90]${green4}";
          "context.java.background" = "[90]${blue6}";
          "context.vi.background" = "[90]${black2}";
          "background" = "[80]${black0}";
          "color0" = "[90]${black0}";
          "cursorBlink" = "true";
          "cursorColor" = gray4;
          "internalBorder" = 16;
          "depth" = 32;
          "fading" = "25";
          "keysym.C-0" = "resize-font:reset";
          "keysym.C-equal" = "resize-font:bigger";
          "keysym.C-minus" = "resize-font:smaller";
          "keysym.C-question" = "resize-font:show";
          "keysym.M-f" = "perl:keyboard-select:search";
          "keysym.M-s" = "perl:keyboard-select:activate";
          "keysym.M-u" = "perl:url-select:select_next";
          "letterSpace" = 0;
          "loginShell" = "true";
          "perl-ext-common" =
            "context,selection-to-clipboard,url-select,resize-font,keyboard-select";
          "perl-lib" = "${pkgs.rxvt-unicode}/lib/urxvt/perl/";
          "secondaryScroll" = "true";
          "urgentOnBell" = "true";
          "url-select.underline" = "true";
        };
      };
    };
  };
}
