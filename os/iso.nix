{ lib, pkgs, modulesPath, ... }:
let palette = import ./palette.nix;
in {
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
  config = {
    isoImage = {
      efiSplashImage = ./../wp/1.jpeg;
      splashImage = ./../wp/1.jpeg;
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
      supportedFilesystems =
        lib.mkForce [ "btrfs" "vfat" "f2fs" "xfs" "ntfs" "ext4" ];
      plymouth = { enable = lib.mkForce false; };
    };
    console = {
      packages = [ pkgs.terminus_font ];
      font = "ter-132n";
      earlySetup = true;
      useXkbConfig = true;
      colors = builtins.map (x: builtins.replaceStrings [ "#" ] [ "" ] x)
        (with palette; [
          black1
          red1
          green1
          yellow1
          blue1
          red3
          cyan1
          white3
          black2
          orange1
          gray1
          gray2
          gray3
          magenta
          red3
          white1
        ]);
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
