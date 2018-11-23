{ config, pkgs, lib, stdenv, self, ... }: {
  home.sessionVariables = {
    JDK_8 = "$HOME/.jdk/8";
    JDK_11 = "$HOME/.jdk/11";
    JDK_16 = "$HOME/.jdk/16";
    JDK_17 = "$HOME/.jdk/17";
    GRAALVM_11 = "$HOME/.jdk/graal-11";
    GRAALVM_17 = "$HOME/.jdk/graal-17";
    GRAALVM_HOME = "$HOME/.jdk/17-graal";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    _JAVA_OPTIONS =
      "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Djdk.gtk.version=3";
    MAVEN_OPTS =
      "-Djava.awt.headless=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS";
  };
  home.activation.installJdks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm --recursive --force "$HOME/.jdk/"
    install --directory --mode 755 --owner="$USER" "$HOME/.jdk/"
    ln --symbolic --force "${pkgs.adoptopenjdk-hotspot-bin-8.out}"  $HOME/.jdk/8
    ln --symbolic --force "${pkgs.adoptopenjdk-hotspot-bin-11.out}" $HOME/.jdk/11
    ln --symbolic --force "${pkgs.adoptopenjdk-hotspot-bin-16.out}" $HOME/.jdk/16
    ln --symbolic --force "${pkgs.openjdk17.out}/lib/openjdk"       $HOME/.jdk/17
    ln --symbolic --force "${pkgs.graalvm11-ce.out}"                $HOME/.jdk/graal-11
    ln --symbolic --force "${pkgs.graalvm17-ce.out}"                $HOME/.jdk/graal-17
  '';
  programs.eclipse = {
    enable = true;
    enableLombok = true;
    package = pkgs.eclipses.eclipse-java;
    plugins = with pkgs.eclipses.plugins; [
      scala
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
          url =
            "https://github.com/IntelliJIdeaKeymap4Eclipse/IntelliJIdeaKeymap4Eclipse-update-site/archive/refs/heads/main.zip";
          sha256 = "sha256-L43JWpYy/9JvOLi9t+UioT/uQbBLL08pgHrW8SuGQ8M=";
        };
      })
    ];
  };
  programs.sbt = {
    enable = true;
    package = pkgs.sbt-with-scala-native;
    plugins = [ ];
  };
  home.file = {
    ".ideavimrc".source = ./../ideavimrc;
    ".local/share/JetBrains/consentOptions/accepted".text = "";
  };
  home.file.".local/bin/jetbrains" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec firejail --profile="${../firejail/idea.profile}" idea-community "$@"
    '';
  };
}
