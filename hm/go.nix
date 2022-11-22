{ config, pkgs, lib, stdenv, self, ... }: {
  config = lib.attrsets.optionalAttrs (self.config.primaryUser.languages.go) {
    programs.go.enable = true;
    home.packages = with pkgs; [
      gotools gocode
    ];
  };
}
