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
      "Emacs*font" = "Terminus";
      "Emacs*scrollBar" = "on";
      "Emacs*scrollBarWidth" = 6;
    };
    services.emacs.enable = lib.mkForce false;
    programs.emacs = {
      enable = config.ao.primaryUser.emacsFromNix;
      extraConfig = ''
         (load-file "${inputs.emacs-d}/init.el")
         (run-hooks (quote after-init-hook))
         (run-hooks (quote emacs-startup-hook))
         (run-hooks (quote window-setup-hook))
      '';
      extraPackages = elpa:
        with elpa; [
          better-defaults
          elfeed
          elpher
          evil
          evil-collection
          exwm
          forge
          go-imports
          magit
          pdf-tools
          telega
          vterm
          xenops
        ];
    };
  };
}
