{ pkgs, ... }: {
  boot.loader = {
    efi.canTouchEfiVariables = false;
    systemd-boot = {
      enable = true;
      configurationLimit = 2;
      extraInstallCommands = with pkgs; ''
        ${perl536}/bin/perl -i -pE 's/^title \s* N.*/title X/x; s/^version \s+ (\S+) \s+ (\S+).*/version $2/x' /boot/loader/entries/*
      '';

      extraFiles = {
        "etc/boot.conf" = pkgs.writeText "boot.conf" ''
          machine gop 3
          set device sr0a
        '';
        "extra/bootx64.efi" = pkgs.fetchurl {
          url = "https://ftp.openbsd.org/pub/OpenBSD/7.2/amd64/BOOTX64.EFI";
          sha256 = "0v8dysfd30clpk9f8sg5157yycwpcw39lrrr7rm88y146icym8c8";
        };
      };
      extraEntries = {
        "unix.conf" = ''
          title OpenBSD
          efi /extra/bootx64.efi
        '';
      };
    };
  };
}
