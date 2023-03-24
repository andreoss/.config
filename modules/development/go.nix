{ config, pkgs, lib, stdenv, self, ... }:
let cfg = config.home.development.go;
in {
  options = {
    home.development.go = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = with pkgs; {
    home.packages = lib.optionals cfg.enable [ gotools gocode ];
  };
}
