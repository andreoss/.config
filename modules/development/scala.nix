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
    services.gnome-keyring.enable = true; # mysql-workbench
    programs.sbt = {
      enable = cfg.enable;
      package = (pkgs.sbt.override { jre = pkgs.openjdk11; });
      plugins = [ ];
    };
    home = lib.mkIf cfg.enable {
      packages = with pkgs; [
        metals
        mill
        nailgun
        dotty
        scalafmt
        ammonite
        httpie
        scalafix
        leiningen
      ];
    };
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        vscodevim.vim
        yzhang.markdown-all-in-one
        scala-lang.scala
        scalameta.metals
      ];
    };
  };
}
