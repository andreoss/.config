{ config, pkgs, lib, stdenv, self, ... }:
let cfg = config.home.development.rust;
in {
  options = {
    home.development.rust = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = {
    home.packages = lib.optionals cfg.enable [ rust-analyzer rustup ];
  };
}
