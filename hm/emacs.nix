{ config, pkgs, lib, stdenv, inputs, ... }: {
  config = {
    programs.emacs = {
      enable = true;
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
    xresources.properties = {
      "Emacs*toolBar" = 0;
      "Emacs*menuBar" = 0;
      "Emacs*geometry" = "80x30";
      "Emacs*font" = "Ttyp0";
      "Emacs*scrollBar" = "on";
      "Emacs*scrollBarWidth" = 6;
    };
    home = {
      file.".local/bin/me" = {
        executable = true;
        text = ''
          #!/bin/sh
          exec emacs -Q -nw -l ${../mini-init.el} "$*"
        '';
      };
      packages = with pkgs; [ nvi ];
      sessionVariables = { EDITOR = "vi"; };
    };
    services.emacs.enable = lib.mkForce true;
  };
}
