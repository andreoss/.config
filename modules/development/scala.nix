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
      package = pkgs.sbt-with-scala-native.overrideDerivation
        (old: { jre = pkgs.openjdk11; });
      plugins = [ ];
    };
    home = lib.mkIf cfg.enable {
      packages = with pkgs; [
        metals
        mill
        nailgun
        dotty
        (google-cloud-sdk.withExtraComponents ([
          google-cloud-sdk.components.cloud-build-local
          google-cloud-sdk.components.gke-gcloud-auth-plugin
        ]))
        trivy
        scalafmt
        ammonite
        httpie
        scalafix
        mysql-workbench
        docker-credential-gcr
        nodejs_20
        nodePackages.yarn
        nodePackages.react-tools
        nodePackages.react-static
        nodePackages.react-native-cli
        nodePackages.typescript
        nodePackages.typescript-language-server
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
