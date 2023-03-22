{ config, pkgs, lib, stdenv, self, ... }:
let
  palette = import ../os/palette.nix;
  python3Plus = pkgs.python3.withPackages
    (ps: with ps; [ pep8 ipython pandas pip meson seaborn pyqt5 tkinter ]);
  python2Plus = pkgs.python27.withPackages (ps: with ps; [ pep8 pip ]);
  my = {
    lang.ruby.packages = with pkgs; [ ruby gem ];
    lang.rust.packages = with pkgs; [ rust-analyzer rustup ];
  };
in {
  nixpkgs.overlays = [
    (self: super: {
      heimdall = super.heimdall.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "deriamis";
          repo = "Heimdall";
          rev = "master";
          sha256 = "sha256-b94W+uwgvPK5TZbMgijFin4kYH0llFajcbtoQdZpnYs=";
        };
      });
    })
  ];
  programs.matplotlib.enable = true;
  home.packages = with pkgs;
    [
      coreutils-full
      file
      oathToolkit
      openvpn
      packer
      rsync
      screen
      (hunspellWithDicts [
        hunspellDicts.ru_RU
        hunspellDicts.es_ES
        hunspellDicts.en_GB-large
      ])
      python3Plus
    ] ++ (lib.optionals (!config.mini && config.ao.primaryUser.office) [
      paperkey
      anki-bin
    ]) ++ (lib.optionals (!config.mini) my.lang.ruby.packages)
    ++ (lib.optionals (!config.mini) my.lang.rust.packages);
  home.file = {
    ".npmrc".source = ./../npmrc;
    ".ratpoisonrc".source = ./../ratpoisonrc;
    ".local/bin/dates".source = ./../scripts/dates;
  };
  home.file.".local/bin/nano" = {
    executable = true;
    text = ''
      #!/bin/sh
      exit 1
    '';
  };
  services.home-manager.autoUpgrade = {
    enable = false;
    frequency = "daily";
  };
  programs.home-manager.enable = true;
}
