{ config, ... }:
{
  virtualisation = {
    kvmgt.enable = !config.minimalInstallation;
    docker = {
      enable = !config.minimalInstallation;
      autoPrune.enable = true;
    };
  };
}
