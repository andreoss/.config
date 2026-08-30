{ config, ... }:
let
  isOn = (x: (builtins.elem x config.features));
in
{
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      lease-database = {
        type = "memfile";
        persist = false;
      };
      interfaces-config = {
        interfaces = [ "virbr0" ];
      };
      subnet4 = [
        {
          id = 1024;
          pools = [ { pool = "203.0.113.100 - 203.0.113.250"; } ];
          reservations = [
            {
              "hw-address" = "00:00:00:00:00:00";
              "ip-address" = "203.0.113.100";
            }
            {
              "hw-address" = "00:00:00:00:00:01";
              "ip-address" = "203.0.113.101";
            }
            {
              "hw-address" = "00:00:00:00:00:02";
              "ip-address" = "203.0.113.102";
            }
          ];
          subnet = "203.0.113.0/24";
        }
      ];
      option-data = [
        {
          "name" = "routers";
          "data" = "203.0.113.1";
        }
      ];
      valid-lifetime = 4000;
    };
  };
  virtualisation = {
    virtualbox.guest = {
      enable = isOn "livecd";
    };
    virtualbox.host = {
      enable = isOn "vm";
      headless = false;
      enableExtensionPack = false;
      enableHardening = false;
    };
    libvirtd.enable = isOn "vm";
  };
}
