{ config, pkgs, lib, stdenv, self, ... }:
let cfg = config.home.development.ruby;
in {
  options = {
    home.development.ruby = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = { home.packages = lib.optionals cfg.enable [ ruby gem ]; };
}
