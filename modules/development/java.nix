{
  config,
  pkgs,
  lib,
  stdenv,
  self,
  ...
}:

let
  merge = builtins.foldl' (x: y: x // y) { };
  mkJdk =
    pkg: var: dir:
    let
      fp = "$HOME/.jdk/${dir}";
    in
    {
      sessionVariables."${var}" = fp;
      activation."${var}" = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        install --directory --mode 700 --owner="$USER" "$HOME/.jdk/"
        rm --force "${fp}"
        ln --symbolic --force "${pkg.out}"  "${fp}"
      '';
    };
  jdks = [
    (mkJdk pkgs.jdk8 "JDK_8" "8")
    (mkJdk pkgs.jdk11 "JDK_11" "11")
    (mkJdk pkgs.jdk17 "JDK_17" "17")
    (mkJdk pkgs.jdk21 "JDK_21" "21")
    (mkJdk pkgs.jdk23 "JDK_23" "23")
    (mkJdk pkgs.temurin-bin-8 "TEMURIN_JDK_8" "temurin-8")
    (mkJdk pkgs.temurin-bin-11 "TEMURIN_JDK_11" "temurin-11")
    (mkJdk pkgs.temurin-bin-17 "TEMURIN_JDK_17" "temurin-17")
    (mkJdk pkgs.temurin-bin-21 "TEMURIN_JDK_21" "temurin-21")
    (mkJdk pkgs.temurin-bin-23 "TEMURIN_JDK_21" "temurin-23")
    (mkJdk pkgs.graalvm-ce "JDK_GRAAL" "graal")
  ];
  variables = merge (map (x: x.sessionVariables) jdks) // {
    MAVEN_OPTS = "-Djava.awt.headless=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
  activationScripts = merge (map (x: x.activation) jdks);
  cfg = config.home.development.java;
in
{
  options = with lib; {
    home.development.java = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = {
    home = lib.mkIf cfg.enable {
      sessionVariables = variables;
      activation = activationScripts;
      file = {
        ".ideavimrc".source = ./ideavimrc;
        ".local/share/JetBrains/consentOptions/accepted".text = "";
        ".local/bin/jetbrains" = {
          executable = true;
          text = ''
            #!/bin/sh
            exec firejail --profile="${../../firejail/idea.profile}" idea-community "$@"
          '';
        };
      };
      packages =
        with pkgs;
        lib.mkIf cfg.enable [
          java-language-server
          android-tools
          ant
          gradle
          groovy
          jetbrains.idea-community
          lombok
          maven
          netbeans
          visualvm
        ];
    };
    programs = {
      java = {
        enable = cfg.enable;
        package = pkgs.openjdk;
      };
      eclipse = {
        enable = config.programs.java.enable;
        enableLombok = config.programs.eclipse.enable;
        package = pkgs.eclipses.eclipse-jee;
        plugins = with pkgs.eclipses.plugins; [
          vrapper
          spotbugs
          color-theme
          cdt
          jsonedit
          drools
          jdt-codemining
          (buildEclipseUpdateSite rec {
            name = "IntelliJIdeaKeymap4Eclipse";
            src = pkgs.fetchzip {
              url = "https://github.com/IntelliJIdeaKeymap4Eclipse/IntelliJIdeaKeymap4Eclipse-update-site/archive/refs/heads/main.zip";
              sha256 = "sha256-L43JWpYy/9JvOLi9t+UioT/uQbBLL08pgHrW8SuGQ8M=";
            };
          })
        ];
      };
    };
  };
}
