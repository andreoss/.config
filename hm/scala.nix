{ config, pkgs, lib, stdenv, self, ... }: {
  config = {
    programs.sbt = {
      enable = config.ao.primaryUser.languages.scala;
      package = pkgs.sbt-with-scala-native;
      plugins = [ ];
    };
    home.packages = with pkgs; [ metals mill nailgun dotty ];
  };
}
