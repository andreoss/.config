{ config, pkgs, lib, ... }:
let
  unstableTarball = fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/master.tar.gz";
  hostname = builtins.replaceStrings ["\n"] [""] (builtins.readFile /etc/hostname);
in
{
  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball { config = config.nixpkgs.config; };
    };
  };
  programs.home-manager.enable = true;
  programs.command-not-found.enable = true;
  programs.autojump.enable = true;
  programs.lf.enable = true;
  programs.jq.enable = true;
  programs.eclipse = {
    enable = true;
    enableLombok = true;
    package = pkgs.eclipses.eclipse-java;
    plugins = [
      pkgs.eclipses.plugins.vrapper
      pkgs.eclipses.plugins.spotbugs
      pkgs.eclipses.plugins.color-theme
    ];
  };
  programs.tmux = {
    enable = true;
    shortcut = "a";
  };
  programs.urxvt = {
    enable = true;
    extraConfig = {};
    fonts = ["xft:Tamzen:size=12"];
  };
  programs.firefox = {
    enable = true;
  };
  programs.emacs = {
    enable = true;
    package = (pkgs.emacs.override {
        withGTK3 = true;
        withGTK2 = false;
      }).overrideAttrs (attrs: {
        configureFlags = [
          "--disable-build-details"
          "--with-modules"
          "--without-toolkit-scroll-bars"
          "--with-x-toolkit=gtk3"
          "--with-xft"
          "--with-cairo"
          "--with-nativecomp"
        ];
      });
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.magit
      epkgs.evil
    ];
  };
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    extraConfig = {
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
    };
    aliases = {
      au   = "add --all";
      cc   = "clone";
      ci   = "commit";
      co   = "checkout";
      fe   = "fetch";
      ll   = "log --one-line";
      me   = "merge";
      pu   = "pull";
      pure = "pull --rebase";
      ri   = "rebase --interactive";
      xx   = "reset HEAD";
    };
  };
  home.username = "a";
  home.homeDirectory = "/home/a";
  home.stateVersion = "20.09";
  home.activation.installJdks = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm --recursive --force "$HOME/.jdk/"
      install --directory --mode 755 --owner="$USER" "$HOME/.jdk/"
      ln --symbolic --force "${pkgs.unstable.adoptopenjdk-hotspot-bin-8.out}"  $HOME/.jdk/8
      ln --symbolic --force "${pkgs.unstable.adoptopenjdk-hotspot-bin-11.out}" $HOME/.jdk/11
      ln --symbolic --force "${pkgs.unstable.adoptopenjdk-hotspot-bin-14.out}" $HOME/.jdk/14
      ln --symbolic --force "${pkgs.unstable.adoptopenjdk-hotspot-bin-15.out}" $HOME/.jdk/15
      ln --symbolic --force "${pkgs.unstable.graalvm8-ce.out}"                 $HOME/.jdk/8-graal
      ln --symbolic --force "${pkgs.unstable.graalvm11-ce.out}"                $HOME/.jdk/11-graal
  '';
  home.activation.installFonts = lib.hm.dag.entryAfter ["writeBoundary"] ''
      install --directory --mode 755 --owner="$USER" "$HOME/.fonts/"
      install --directory --mode 755 --owner="$USER" "$HOME/.fonts/comic-mono/"
      wget https://dtinth.github.io/comic-mono-font/ComicMono.ttf \
                --continue                                        \
                --directory-prefix=$HOME/.fonts/comic-mono/
      wget https://dtinth.github.io/comic-mono-font/ComicMono-Bold.ttf \
                --continue                                        \
                --directory-prefix=$HOME/.fonts/comic-mono/
  '';
  home.sessionVariables = {
    JDK_8 = "$HOME/.jdk/8";
    JDK_11 = "$HOME/.jdk/11";
    JDK_14 = "$HOME/.jdk/14";
    JDK_15 = "$HOME/.jdk/15";
    GRAALVM_8 = "$HOME/.jdk/8-graal";
    GRAALVM_11 = "$HOME/.jdk/11-graal";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    MAVEN_OPTS = "-Djava.awt.headless=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS";
  };
  home.packages = with pkgs; [
    cloc
    ack
    ripgrep
    xterm
    atool
    unzip
    wget
    gnupg
    coreutils
    mc
    openshift
    docker
    gitAndTools.git-codeowners
    gitAndTools.gitflow
    unstable.maven
    unstable.gradle
    unstable.jetbrains.idea-community
    umlet
    shellcheck
    iosevka
    tamzen
  ];
  gtk.theme = "Adwaita";
  xresources.properties = {
    "Emacs*font" = "Comic Mono-14";
    "Emacs*geometry" = "80x40";
    "Emacs.scrollBar" = "on";
    "Emacs.scrollBarWidth" =  6;
  };
  services.stalonetray.enable = true;
}
