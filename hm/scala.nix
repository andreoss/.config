{ config, pkgs, lib, ... }:
let cfg = config.home.development.scala;
in {
  options = with lib; {
    home.development.scala = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = {
    programs.sbt = {
      enable = cfg.enable;
      package = pkgs.sbt-with-scala-native;
      plugins = [ ];
    };
    home = lib.mkIf cfg.enable {
      packages = with pkgs; [ metals mill nailgun dotty ];
    };
  };
}
