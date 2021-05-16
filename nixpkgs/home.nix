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
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };
  programs.command-not-found.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableNixDirenvIntegration = true;
  };
  programs.autojump.enable = true;
  programs.lf.enable = true;
  programs.jq.enable = true;
  programs.eclipse = {
    enable = true;
    enableLombok = true;
    package = pkgs.unstable.eclipses.eclipse-java;
    plugins = with pkgs.unstable.eclipses.plugins; [
      vrapper
      spotbugs
      color-theme
    ];
  };
  programs.tmux = {
    enable = true;
    shortcut = "a";
  };
  programs.urxvt = {
    enable = true;
    package = pkgs.rxvt_unicode-with-plugins;
    iso14755 = true;
    fonts = ["xft:Tamzen:size=12"];
    scroll = {
      bar.enable = true;
      bar.style = "plain";
      lines = 65535;
      scrollOnOutput = false;
      scrollOnKeystroke = true;
    };
    extraConfig = {
      "perl-ext-common" = [ "selection-to-clipboard"];
      "letterSpace" = -1;
      "loginShell" = "true";
      "urgentOnBell" = "true";
      "secondaryScroll" = "true";
      "cursorColor" = "#afbfbf";
      "cursorBlink" = "true";
      "internalBorder" = 24;
      "depth" = 24;
      "background" = "#101010"; "foreground" = "#aeaeae";
      "color0"  = "#101010"; "color8"  = "#353535";
      "color1"  = "#AE0050"; "color9"  = "#FA3A99";
      "color2"  = "#69AE11"; "color10" = "#44FA80";
      "color3"  = "#C47F2C"; "color11" = "#FABE9A";
      "color4"  = "#4040AE"; "color12" = "#4F4FEA";
      "color5"  = "#7E43AE"; "color13" = "#AB88DE";
      "color6"  = "#4979AE"; "color14" = "#4EB9FA";
      "color7"  = "#A999AE"; "color15" = "#D3D0D0";
    };
  };
  programs.emacs = {
    overrides = self: super: rec {
      telega = pkgs.unstable.emacsPackages.telega;
      evil = pkgs.unstable.emacsPackages.evil;
      magit = pkgs.unstable.emacsPackages.magit;
    };
    enable = true;
    package = (pkgs.emacs.override {
        withGTK3 = false;
        withGTK2 = false;
      }).overrideAttrs (attrs: {
        configureFlags = [
          "--disable-build-details"
          "--with-modules"
          "--without-toolkit-scroll-bars"
          "--with-x-toolkit=no"
          "--with-xft"
          "--with-cairo"
          "--with-nativecomp"
        ];
      });
    extraPackages = epkgs: [
      epkgs.ag
      epkgs.aggressive-indent
      epkgs.auto-compile
      epkgs.avy
      epkgs.backup-each-save
      epkgs.bash-completion
      epkgs.beacon
      epkgs.better-defaults
      epkgs.browse-kill-ring
      epkgs.bug-reference-github
      epkgs.cargo
      epkgs.ccls
      epkgs.c-eldoc
      epkgs.centered-cursor-mode
      epkgs.cider
      epkgs.clojure-mode
      epkgs.company
      epkgs.company-c-headers
      epkgs.company-lua
      epkgs.company-prescient
      epkgs.counsel
      epkgs.dashboard
      epkgs.default-text-scale
      epkgs.digit-groups
      epkgs.dired-narrow
      epkgs.dired-subtree
      epkgs.dumb-jump
      epkgs.editorconfig
      epkgs.elisp-lint
      epkgs.elisp-slime-nav
      epkgs.eros
      epkgs.eval-sexp-fu
      epkgs.expand-region
      epkgs.exwm
      epkgs.feebleline
      epkgs.flx
      epkgs.flx-ido
      epkgs.flycheck
      epkgs.flycheck-inline
      epkgs.flycheck-rust
      epkgs.fringe-current-line
      epkgs.fullframe
      epkgs.general
      epkgs.gitconfig
      epkgs.git-gutter
      epkgs.gitignore-mode
      epkgs.go-autocomplete
      epkgs.go-eldoc
      epkgs.go-guru
      epkgs.golint
      epkgs.go-mode
      epkgs.groovy-mode
      epkgs.guix
      epkgs.helm
      epkgs.helpful
      epkgs.highlight
      epkgs.hl-todo
      epkgs.hydra
      epkgs.ivy
      epkgs.ivy-prescient
      epkgs.keyfreq
      epkgs.kotlin-mode
      epkgs.langtool
      epkgs.lispy
      epkgs.forge
      epkgs.emacsql
      epkgs.nix-mode
      epkgs.notmuch
      epkgs.ob-restclient
      epkgs.org-bullets
      epkgs.org-caldav
      epkgs.org-evil
      epkgs.org-jira
      epkgs.org-pdftools
      epkgs.page-break-lines
      epkgs.paredit
      epkgs.pdf-tools
      epkgs.persistent-scratch
      epkgs.projectile
      epkgs.pyvenv
      epkgs.quelpa-use-package
      epkgs.quick-peek
      epkgs.rainbow-mode
      epkgs.raku-mode
      epkgs.restart-emacs
      epkgs.reverse-im
      epkgs.rust-mode
      epkgs.sbt-mode
      epkgs.scala-mode
      epkgs.selectrum
      epkgs.session
      epkgs.slime
      epkgs.slime-company
      epkgs.telega
      epkgs.typescript-mode
      epkgs.undo-tree
      epkgs.unkillable-scratch
      epkgs.use-package
      epkgs.vlf
      epkgs.vterm
      epkgs.which-key
      epkgs.winum
      epkgs.yasnippet
      epkgs.ytdl
      epkgs.ghub
      epkgs.emms
      epkgs.evil-exchange
      epkgs.evil-matchit
      epkgs.clj-refactor
      epkgs.aggressive-indent
    ];
  };
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = {
      au   = "add --all";
      cc   = "clone";
      ci   = "commit";
      co   = "checkout";
      fe   = "fetch";
      ll   = "log --oneline";
      me   = "merge";
      pu   = "pull";
      pure = "pull --rebase";
      ri   = "rebase --interactive";
      xx   = "reset HEAD";
    };
  };
  programs.firefox= {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      https-everywhere
      tridactyl
      ublock-origin
    ];
  };
  home.username = "a";
  home.homeDirectory = "/home/a";
  home.stateVersion = "20.09";
  home.activation.installJdks = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm --recursive --force "$HOME/.jdk/"
      install --directory --mode 755 --owner="$USER" "$HOME/.jdk/"
      ln --symbolic --force "${pkgs.unstable.adoptopenjdk-hotspot-bin-8.out}"  $HOME/.jdk/8
      ln --symbolic --force "${pkgs.unstable.adoptopenjdk-hotspot-bin-11.out}" $HOME/.jdk/11
      ln --symbolic --force "${pkgs.unstable.adoptopenjdk-hotspot-bin-16.out}" $HOME/.jdk/16
      ln --symbolic --force "${pkgs.unstable.graalvm8-ce.out}"                 $HOME/.jdk/8-graal
      ln --symbolic --force "${pkgs.unstable.graalvm11-ce.out}"                $HOME/.jdk/11-graal
  '';
  home.activation.installFonts = lib.hm.dag.entryAfter ["writeBoundary"] ''
      install --directory --mode 755 --owner="$USER" "$HOME/.fonts/"
      install --directory --mode 755 --owner="$USER" "$HOME/.fonts/comic-mono/"
      if [ ! -d "$HOME/.fonts/comic-mono" ]
      then
          ${pkgs.wget.out}/bin/wget https://dtinth.github.io/comic-mono-font/ComicMono.ttf \
                    --continue                                        \
                    --directory-prefix=$HOME/.fonts/comic-mono/
          ${pkgs.wget.out}/bin/wget https://dtinth.github.io/comic-mono-font/ComicMono-Bold.ttf \
                    --continue                                        \
                    --directory-prefix=$HOME/.fonts/comic-mono/
      fi
      for DIR in "$HOME/.fonts"/*
      do
         ${pkgs.xorg.mkfontdir.out}/bin/mkfontdir "$DIR"
         ${pkgs.xorg.xset.out}/bin/xset +fp "$DIR"
      done
      ${pkgs.xorg.xset.out}/bin/xset fp rehash
      ${pkgs.fontconfig.bin}/bin/fc-cache
  '';
  home.sessionVariables = {
    JDK_8 = "$HOME/.jdk/8";
    JDK_11 = "$HOME/.jdk/11";
    JDK_14 = "$HOME/.jdk/14";
    JDK_16 = "$HOME/.jdk/16";
    GRAALVM_8 = "$HOME/.jdk/8-graal";
    GRAALVM_11 = "$HOME/.jdk/11-graal";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    MAVEN_OPTS = "-Djava.awt.headless=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS";
  };
  home.packages = with pkgs; [
    notmuch
    davmail
    isync
    msmtp
    pkg-config
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
    gitAndTools.git-extras
    mercurialFull
    ant
    clojure
    clojure-lsp
    gradle
    groovy
    unstable.jetbrains.idea-community
    unstable.netbeans
    leiningen
    lombok
    maven
    unstable.metals
    sbt
    visualvm
    umlet
    shellcheck
    iosevka
    tamzen
    uw-ttyp0
    nix
    xorg.xdpyinfo
    xorg.xmessage
    unstable.nyxt
    lispPackages.dbus
    lispPackages.external-program
    lispPackages.bordeaux-threads
    lispPackages.quicklisp
    lispPackages.swank
    lispPackages.stumpwm
    imagemagick7Big
    ffmpeg-full
    mpv
  ];
  xresources.properties = {
    "Emacs*font" = "Iosevka-14";
    "Emacs*geometry" = "80x40";
    "Emacs.scrollBar" = "on";
    "Emacs.scrollBarWidth" =  6;
  };
  programs.rofi.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
  services.cbatticon.enable = true;
  services.emacs.enable = true;
  services.keynav.enable = true;
  services.network-manager-applet.enable = true;
  services.pasystray.enable = true;
  home.file.".shrc".source = ~/.config/shrc;
  home.file.".inputrc".source = ~/.config/inputrc;
  home.file.".ratpoisonrc".source = ~/.config/ratpoisonrc;
}
