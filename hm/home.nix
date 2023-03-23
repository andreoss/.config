{ config, pkgs, lib, stdenv, self, ... }:
let palette = import ../os/palette.nix;
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
  home.packages = with pkgs; [
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
    paperkey
    anki-bin
  ];
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
