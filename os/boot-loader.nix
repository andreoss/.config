{ pkgs, ... }: {
  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot = {
      enable = true;
      configurationLimit = 2;
      extraInstallCommands = with pkgs; ''
        ${perl536}/bin/perl -i -pE 's/^title \s* N.*/title X/x; s/^version \s+ (\S+) \s+ (\S+).*/version $2/x' /boot/loader/entries/*
      '';

    };
  };
}
