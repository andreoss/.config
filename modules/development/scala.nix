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
      package = (pkgs.sbt.override { jre = pkgs.openjdk21; });
      plugins = [ ];
    };
    home = lib.mkIf cfg.enable {
      sessionVariables = { "SBT_OPTS" = "-Xmx32G"; };
      packages = with pkgs; [
        coursier
        dotty
        httpie
        leiningen
        metals
        mill
        nailgun
        scalafix
        scalafmt
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
