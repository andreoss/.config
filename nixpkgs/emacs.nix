{ config, pkgs, lib, stdenv, self, ... }: {
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
    extraPackages = elpa:
      with elpa; [
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
        better-defaults
      ];
  };
}
