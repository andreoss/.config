{ pkgs, lib, self, ... }:
let user = self.config.primaryUser.name;
in {
  services.usbguard = {
    enable = (lib.pathExists ./usb-whitelist);
    IPCAllowedUsers = [ user "root" ];
    rules = if (lib.pathExists ./usb-whitelist) then
      (builtins.readFile ./usb-whitelist)
    else
      "";
  };
  programs.firejail = {
    enable = true;
    wrappedBinaries = { };
  };
  security.wrappers = {
    firejail.source = "${pkgs.firejail.out}/bin/firejail";
  };
  security.lockKernelModules = false;
  security.forcePageTableIsolation = true;
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    extraRules = [
      {
        users = [ user ];
        commands = [{
          command = "${pkgs.systemd}/bin/systemctl";
          options = [ "NOPASSWD" ];
        }];
      }
      {
        users = [ user ];
        commands = [{
          command = "${pkgs.systemd}/bin/reboot";
          options = [ "NOPASSWD" ];
        }];
      }
      {
        users = [ user ];
        commands = [{
          command = "${pkgs.systemd}/bin/halt";
          options = [ "NOPASSWD" ];
        }];
      }
      {
        users = [ user ];
        commands = [{
          command = "${pkgs.procps}/bin/pkill";
          options = [ "NOPASSWD" ];
        }];
      }
      {
        users = [ user ];
        commands = [{
          command = "${pkgs.coreutils}/bin/kill";
          options = [ "NOPASSWD" ];
        }];
      }
    ];
    extraConfig = "Defaults lecture=never";
  };
}
