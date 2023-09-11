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
      "Emacs*font" = "Terminus";
      "Emacs*geometry" = "80x48";
      "Emacs*scrollBar" = "on";
      "Emacs*scrollBarWidth" = 6;
    };
    home = {
      file.".local/bin/emacs-nox" = {
        executable = true;
        text = ''
          #!/bin/sh
          PATH=${inputs.emacs-d.packages.x86_64-linux.emacs-nox.out}/bin:$PATH
          exec emacs "$*"
        '';
      };
      file.".local/bin/emacs-pgtk" = {
        executable = true;
        text = ''
          #!/bin/sh
          PATH=${inputs.emacs-d.packages.x86_64-linux.emacs-pgtk.out}/bin:$PATH
          JAVA_HOME="${pkgs.pkgs.adoptopenjdk-hotspot-bin-11.out}"
          PATH=$PATH:$JAVA_HOME/bin
          exec emacs "$*"
        '';
      };
      file.".local/bin/me" = {
        executable = true;
        text = ''
          #!/bin/sh
          exec emacs -Q -nw -l ${../mini-init.el} "$*"
        '';
      };
      packages = with pkgs; [
        nvi
        coreutils-full
        (hunspellWithDicts [
          hunspellDicts.ru_RU
          hunspellDicts.es_ES
          hunspellDicts.en_GB-large
        ])
      ];
      sessionVariables = { EDITOR = "vi"; };
    };
    services.emacs.enable = lib.mkForce true;
  };
}
