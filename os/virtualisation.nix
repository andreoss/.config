{ config, ... }:
let
  isOn = (x: (builtins.elem x config.features));
in
{
  security.polkit.enable = true;
  systemd.services.dockerd.environment = { };
  systemd.services.docker = {
    serviceConfig = {
      LimitNOFILE = 65536;
    };
  };
  programs.extra-container.enable = true;
  networking = {
    bridges.virbr0 = {
      interfaces = [ ];
    };
    interfaces.virbr0 = {
      ipv4.addresses = [
        {
          address = "203.0.113.1";
          prefixLength = 24;
        }
      ];
    };
    nat.internalInterfaces = [
      "ve-+"
      "virbr0"
    ];
    firewall = {
      trustedInterfaces = [
        "docker0"
        "virbr*"
      ];
    };
  };
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
    kvmgt.enable = !config.minimalInstallation;
    docker = {
      enable = !config.minimalInstallation;
      autoPrune.enable = true;
    };
    virtualbox.guest = {
      enable = isOn "livecd";
    };
    virtualbox.host = {
      enable = !(config.minimalInstallation || isOn "livecd") && isOn "virtualbox";
      headless = false;
      enableExtensionPack = true;
      enableHardening = false;
    };
    libvirtd.enable = isOn "vm";
  };
  users =
    let
      user = config.primaryUser.name;
    in
    {
      groups = {
        docker.members = [ user ];
        libvirtd.members = [ user ];
        lxd.members = [ user ];
        vboxusers.members = [ user ];
      };
    };
}
