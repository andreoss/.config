{pkgs, ... }:
{
  xresources.properties = {
    "XTerm*charClass" = [ "37:48" "45-47:48" "58:48" "64:48" "126:48" ];
  };
  home.file = {
    ".screenrc".source = ./../screenrc;
  };
  home.file.".local/bin/xscreen" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec urxvt -e screen -D -R -S "$\{1:-primary}" "$*"
    '';
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
    extraConfig = {
      "context.names" = "sudo,ssh,python,gdb,java";
      "context.sudo.background" = "[90]#8F0000";
      "context.ssh.background " = "[90]#28488A";
      "context.python.background" = "[90]#245488";
      "context.gdb.background" = "[90]#236823";
      "context.java.background" = "[90]#28381A";
      "background" = "[80]#000000";
      "color0" = "[90]#000000"; # Color: Black        ~ 0
      "color1" = "#AA1F1F"; # Color: Red          ~ 1
      "color2" = "#468747"; # Color: Green        ~ 2
      "color3" = "#8F7734"; # Color: Yellow       ~ 3
      "color4" = "#568BD2"; # Color: Blue         ~ 4
      "color5" = "#888ACA"; # Color: Magenta      ~ 5
      "color6" = "#6AA7A8"; # Color: Cyan         ~ 6
      "color7" = "#F3F3D3"; # Color: White        ~ 7
      "color8" = "#878781"; # Color: BrightBlack  ~ 8
      "color9" = "#FFADAD"; # Color: BrightRed    ~ 9
      "color10" = "#EBFFEB"; # Color: BrightGreen  ~ 10
      "color11" = "#EDEEA5"; # Color: BrightYellow ~ 11
      "color12" = "#EBFFFF"; # Color: BrightBlue   ~ 12
      "color13" = "#A1EEED"; # Color: BrightCyan   ~ 14
      "color14" = "#96D197"; # Color: MidGreen     ~ 13
      "color15" = "#FFFFEB"; # Color: BrightWhite  ~ 15
      "cursorBlink" = "true";
      "cursorColor" = "#AFBFBF";
      "internalBorder" = 16;
      "depth" = 32;
      "foreground" = "#F3F3D3";
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
    };
  };
}
