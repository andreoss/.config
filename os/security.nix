{
  pkgs,
  lib,
  config,
  ...
}:
let
  user = config.primaryUser.name;
in
{
  services.usbguard = {
    enable = (lib.pathExists ./usb-whitelist);
    IPCAllowedUsers = [
      user
      "root"
    ];
    rules = if (lib.pathExists ./usb-whitelist) then (builtins.readFile ./usb-whitelist) else "";
  };
  programs.firejail = {
    enable = true;
    wrappedBinaries = { };
  };
  services.physlock = {
    enable = lib.mkForce true;
    allowAnyUser = true;
  };
  security = {
    lockKernelModules = false;
    forcePageTableIsolation = true;
    sudo =
      let
        nopass = cmd: {
          users = [ user ];
          commands = [
            {
              command = "/run/current-system/sw/bin/${cmd}";
              options = [ "NOPASSWD" ];
            }
          ];
        };
      in
      {
        enable = true;
        wheelNeedsPassword = config.autoLock.enable;
        extraConfig = "Defaults lecture=never";
        extraRules = lib.mkIf config.autoLock.enable [
          (nopass "kill")
          (nopass "pkill")
          (nopass "halt")
          (nopass "reboot")
          (nopass "systemctl")
          (nopass "rfkill")
        ];
      };
  };
}
