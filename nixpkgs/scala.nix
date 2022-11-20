{ config, pkgs, lib, stdenv, self, ... }: {
  config = lib.attrsets.optionalAttrs (self.config.primaryUser.languages.scala) {
    programs.sbt = {
      enable = true;
      package = pkgs.sbt-with-scala-native;
      plugins = [ ];
    };
    home.packages = with pkgs; [ metals mill nailgun dotty ];
  };
}
