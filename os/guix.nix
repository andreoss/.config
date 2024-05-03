{ config, pkgs, ... }:
{
  services.guix = {
    enable = true;
    gc = {
      enable = true;
    };
  };
}
