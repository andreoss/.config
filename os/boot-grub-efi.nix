{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = {
    boot.loader = {
      efi.efiSysMountPoint = "/boot/efi";
      efi.canTouchEfiVariables = false;
      grub = {
        configurationName = "${config.environment.etc."nixos/version".text} ${
          config.environment.etc."nixos/date".text
        }";
        configurationLimit = 3;
        devices = [ "nodev" ];
        efiInstallAsRemovable = true;
        efiSupport = true;
        enableCryptodisk = true;
        enable = true;
        font = "${pkgs.terminus_font_ttf}/share/fonts/truetype/TerminusTTF-Bold.ttf";
        fontSize = 36;
        splashImage = config.backgroundImage;
        splashMode = "stretch";
        theme = null;
      };
    };
  };
}
