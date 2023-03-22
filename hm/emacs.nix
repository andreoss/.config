{ config, pkgs, lib, stdenv, inputs, ... }: {
  config = {
    home.file.".local/bin/me" = {
      executable = true;
      text = ''
        #!/bin/sh
        exec emacs -Q -nw -l ${../mini-init.el} "$*"
      '';
    };
    home.packages = with pkgs; [ nvi ];
    home.sessionVariables = { EDITOR = "vi"; };
    xresources.properties = {
      "Emacs*toolBar" = 0;
      "Emacs*menuBar" = 0;
      "Emacs*geometry" = "80x30";
      "Emacs*font" = "Ttyp0";
      "Emacs*scrollBar" = "on";
      "Emacs*scrollBarWidth" = 6;
    };
    services.emacs.enable = lib.mkForce true;
    programs.emacs = {
      enable = config.ao.primaryUser.emacsFromNix;
      package = inputs.emacs-d.packages.x86_64-linux.emacs;
    };
    editorconfig = {
      enable = true;
      settings = {
        "*" = {
          end_of_line = "lf";
          trim_trailing_whitespace = true;
          insert_final_newline = true;
        };
      };
    };
  };
}
