{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.home.development.scala;
in
{
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
      package = (pkgs.sbt.override { jre = pkgs.openjdk21; });
      plugins = [ ];
    };
    home = lib.mkIf cfg.enable {
      sessionVariables = {
      };
      file.".local/bin/sbt-17" =
        let
          sbt-script = (
            pkgs.writeShellScript "sbt-17" ''
              PATH=${
                lib.strings.makeBinPath [
                  (pkgs.sbt.override { jre = pkgs.openjdk17; })
                  pkgs.openjdk17
                ]
              }:$PATH
              exec "sbt" "$@"
            ''
          );
        in
        {
          executable = true;
          text = ''
            #!/bin/sh
            exec ${sbt-script} "$@"
          '';
        };
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
        scala-lang.scala
        scalameta.metals
        vscodevim.vim
        yzhang.markdown-all-in-one
      ];
    };
  };
}
