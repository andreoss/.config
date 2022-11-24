{ config, pkgs, lib, stdenv, self, inputs, ... }: {
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
      enable = self.config.primaryUser.emacsFromNix;
      package = pkgs.emacs.override {
        withToolkitScrollBars = false;
        withAthena = true;
        nativeComp = true;
      };
      extraConfig = ''
        (load-file "${../mini-init.el}")
        (make-thread #'(lambda ()
            (load-file "${inputs.emacs-d}/init.el")
            (run-hooks (quote after-init-hook))
            (run-hooks (quote emacs-startup-hook))
            (run-hooks (quote window-setup-hook))
        ) "init")
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
