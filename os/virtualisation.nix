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
