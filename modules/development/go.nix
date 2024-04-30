{
  config,
  pkgs,
  lib,
  stdenv,
  self,
  ...
}:
let
  cfg = config.home.development.go;
in
{
  options = {
    home.development.go = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    programs.go = {
      enable = true;
      packages = { };
    };
    home.packages = with pkgs; [
      gotools
      gocode
    ];
  };
}
