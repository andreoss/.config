{ pkgs, inputs, ... }:
let palette = import ../os/palette.nix;
in {
  xresources.properties = {
    "XTerm*charClass" = [ "37:48" "45-47:48" "58:48" "64:48" "126:48" ];
  };
  home.sessionVariables = { EDITOR = "vi"; };
  home.file = {
    ".screenrc".source = ./../screenrc;
    ".urxvt/ext/context".text =
      builtins.readFile "${inputs.urxvt-context-ext}/context";
    ".local/bin/xscreen" = {
      executable = true;
      text = ''
        #!/bin/sh
        exec urxvt -e screen -D -R -S "$\{1:-primary}" "$*"
      '';
    };
  };
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    shortcut = "a";
  };
  programs.urxvt = {
    enable = true;
    package = pkgs.rxvt-unicode-unwrapped;
    iso14755 = true;
    fonts = [ "xft:Terminus" ];
    scroll = {
      bar = {
        enable = true;
        style = "plain";
      };
      lines = 10000000;
      scrollOnOutput = false;
      scrollOnKeystroke = true;
    };
    extraConfig = (with palette; {
      "context.names" = "sudo,ssh,python,gdb,java,vi";
      "context.sudo.background" = "[90]${red3}";
      "context.ssh.background " = "[90]${blue4}";
      "context.python.background" = "[90]${blue3}";
      "context.gdb.background" = "[90]${green2}";
      "context.java.background" = "[90]${gray2}";
      "context.vi.background" = "[90]${gray1}";
      "background" = "[80]${black1}";
      "color0" = "[90]${black1}";
      "color1" = red1;
      "color2" = green2;
      "color3" = yellow1;
      "color4" = blue1;
      "color5" = magenta;
      "color6" = cyan1;
      "color7" = white1;
      "color8" = gray2;
      "color9" = red2;
      "color10" = green3;
      "color11" = yellow2;
      "color12" = blue5;
      "color13" = cyan2;
      "color14" = green2;
      "color15" = white2;
      "cursorBlink" = "true";
      "cursorColor" = gray4;
      "internalBorder" = 16;
      "depth" = 32;
      "foreground" = white3;
      "keysym.C-0" = "resize-font:reset";
      "keysym.C-equal" = "resize-font:bigger";
      "keysym.C-minus" = "resize-font:smaller";
      "keysym.C-question" = "resize-font:show";
      "keysym.M-f" = "perl:keyboard-select:search";
      "keysym.M-s" = "perl:keyboard-select:activate";
      "keysym.M-u" = "perl:url-select:select_next";
      "letterSpace" = -1;
      "loginShell" = "true";
      "perl-ext-common" =
        "context,selection-to-clipboard,url-select,resize-font,keyboard-select";
      "perl-lib" = "${pkgs.rxvt-unicode}/lib/urxvt/perl/";
      "secondaryScroll" = "true";
      "urgentOnBell" = "true";
      "url-select.underline" = "true";
    });
  };
}
