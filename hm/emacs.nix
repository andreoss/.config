{ config, pkgs, lib, stdenv, inputs, ... }: {
  config = {
    home.file.".local/bin/me" = {
      executable = true;
      text = ''
        #!/bin/sh
        exec emacs -Q -nw -l ${../mini-init.el} "$*"
      '';
    };
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
      extraConfig = builtins.readFile (pkgs.substituteAll {
        src = ../init.el;
        jc = inputs.jc-themes;
        autofmt = inputs.elisp-autofmt;
      });
      extraPackages = elpa:
        let
          packageListNix =
            pkgs.runCommand "init-packages.nix" { input = ../init.el; } ''
              ${pkgs.perl}/bin/perl -007 -nE '
              BEGIN {
                  say "{elpa, ...}: with elpa; [";
                  say "use-package";
              };
              END   { say "]" };
              while (m{[(]use-package \s* ([a-z-0-9]+) \s* (;\S+)?}xsgm) {
                 next if $2 eq ";builtin";
                 say $1;
              }' "$input" >"$out" 
            '';
        in (import "${packageListNix}" { inherit elpa; });
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
