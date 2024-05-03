{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
let
  palette = import ./palette.nix;
in
{
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
  config = {
    isoImage = {
      efiSplashImage = config.backgroundImage;
      splashImage = config.backgroundImage;
    };
    boot = {
      initrd = {
        verbose = false;
        availableKernelModules = lib.mkForce [
          "ahci"
          "ehci_pci"
          "rtsx_pci_sdmmc"
          "sata_nv"
          "sd_mod"
          "uhci_hcd"
          "usb_storage"
          "xhci_pci"
        ];
      };
      supportedFilesystems = lib.mkForce [
        "btrfs"
        "vfat"
        "f2fs"
        "xfs"
        "ntfs"
        "ext4"
      ];
    };
    boot.plymouth = {
      enable = true;
      theme = "bgrt";
      logo = config.backgroundImage;
      font = "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF-Bold.ttf";
    };
    systemd.extraConfig = lib.mkForce ''
      DefaultTimeoutStartSec=10s
      DefaultTimeoutStopSec=10s
      DefaultOOMPolicy=kill
      ShowStatus=error
    '';
    services.gpm.enable = lib.mkForce true;
    services.xserver.displayManager.gdm.enable = lib.mkForce false;
    services.xserver.displayManager.lightdm.enable = lib.mkForce false;
    services.xserver.displayManager.sddm.enable = lib.mkForce false;
  };
}
