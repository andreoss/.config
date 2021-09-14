{ config, pkgs, lib, fetchurl, stdenv, ... }:
let
  unstableTarball = fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/master.tar.gz";
  hostname = builtins.replaceStrings ["\n"] [""] (builtins.readFile /etc/hostname);
  onHost = hosts: builtins.any (s: s == hostname) hosts;
  onLocal = onHost [ "thnk" "vtfn" ];
  ifOnHost = host: result: alternative: if (onHost host) then result else alternative;
  ifOnLocal = ((ifOnHost) ["thnk" "vtfn" ]);
  sbclPackages = with pkgs.lispPackages; [
    dbus
    external-program
    bordeaux-threads
    quicklisp
    swank
    stumpwm
  ];
  jdkRelatedPackages = with pkgs.unstable; [
    ant
    clojure
    clojure-lsp
    gradle
    groovy
    jetbrains.idea-community
    leiningen
    lombok
    maven
    metals
    netbeans
    sbt
    visualvm
    umlet
  ];
  fontPackages = with pkgs; [
    paratype-pt-mono
    iosevka
    uw-ttyp0
    terminus_font_ttf
    gentium
    unifont
    sudo-font
    dina-font
  ];
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
  };
  programs.lf.enable = true;
  programs.jq.enable = true;
  programs.eclipse = {
    enable = true;
    enableLombok = true;
    package = pkgs.eclipses.eclipse-java;
    plugins = with pkgs.eclipses.plugins; [
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
    fonts = ["xft:Ttyp0:size=10"];
    scroll = {
      bar = {
        enable = true;
        style = "plain";
      };
      lines = 65535;
      scrollOnOutput = false;
      scrollOnKeystroke = true;
    };
    extraConfig = {
      "perl-lib" = "${pkgs.rxvt-unicode}/lib/urxvt/perl/";
      "perl-ext-common" = "selection-to-clipboard,url-select,resize-font,keyboard-select";
      "keysym.M-u" = "perl:url-select:select_next";
      "keysym.M-f" = "perl:keyboard-select:search";
      "keysym.M-s" = "perl:keyboard-select:activate";
      "keysym.C-minus" = "resize-font:smaller";
      "keysym.C-equal" = "resize-font:bigger";
      "keysym.C-0" = "resize-font:reset";
      "keysym.C-question" = "resize-font:show";
      "url-select.underline" = "true";
      "letterSpace" = -1;
      "loginShell" = "true";
      "urgentOnBell" = "true";
      "secondaryScroll" = "true";
      "cursorColor" = "#afbfbf";
      "cursorBlink" = "true";
      "internalBorder" = 24;
      "depth" = 32;
      "background" = "rgba:0000/0000/0200/c800"; "foreground" = "#aeaeae";
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
      evil-collection = pkgs.unstable.emacsPackages.evil-collection;
      magit = pkgs.unstable.emacsPackages.magit;
      forge = pkgs.unstable.emacsPackages.forge;
    };
    enable = true;
    # extraConfig = ''
    #   (require 'better-defaults)
    #   (require 'evil)
    #   (evil-mode +1)
    # '';
    package = (pkgs.unstable.emacs.override {
      withGTK3 = false;
      withGTK2 = false;
      srcRepo = false;
    }).overrideAttrs (attrs: {
      configureFlags = [
        "--disable-build-details"
        "--with-modules"
        "--without-toolkit-scroll-bars"
        "--with-x-toolkit=athena"
        "--with-xft"
        "--with-cairo"
        "--with-nativecomp"
      ];
    });
    extraPackages = epkgs: [
      epkgs.magit
      epkgs.better-defaults
      epkgs.forge
      epkgs.evil
      epkgs.evil-collection
      epkgs.vterm
      epkgs.pdf-tools
      epkgs.telega
    ];
  };
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    extraConfig = {
      init = {
        defaultBranch = "master";
      };
    };
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
  programs.chromium = {
    enable = true;
    #package = pkgs.unstable.ungoogled-chromium;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm"
      "gcbommkclmclpchllfjekcdonpmejbdp"
      "haiffjcadagjlijoggckpgfnoeiflnem"
      "dbepggeogbaibhgnhhndojpepiihcmeb"
      "ldpochfccmkkmhdbclfhpagapcfdljkj"
    ];
  };
  programs.firefox= {
    enable = false;
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
  programs.bash = {
    enableVteIntegration = true;
    shellAliases = {
      vi = "emacsclient -t";
    };
  };
  home.sessionVariables = {
    JDK_8 = "$HOME/.jdk/8";
    JDK_11 = "$HOME/.jdk/11";
    JDK_16 = "$HOME/.jdk/16";
    GRAALVM_8 = "$HOME/.jdk/8-graal";
    GRAALVM_11 = "$HOME/.jdk/11-graal";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    MAVEN_OPTS = "-Djava.awt.headless=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS";
  };
  home.packages = with pkgs; [
    gitAndTools.git-codeowners
    gitAndTools.git-extras
    gitAndTools.gitflow
    davmail
    ack
    atool
    cloc
    coreutils
    docker
    gnupg
    imagemagick7Big
    mc
    mercurialFull
    nix
    openshift
    pkg-config
    ripgrep
    shellcheck
    unzip
    wget
    xorg.xdpyinfo
    xorg.xmessage
    mpv
    ffmpeg-full
    pass
  ] ++ fontPackages ++ (ifOnLocal sbclPackages []) ++ jdkRelatedPackages;
  fonts.fontconfig.enable = true;
  gtk = {
    enable = true;
    font = {
      package = pkgs.sudo-font;
      name = "Sudo";
    };
    gtk2.extraConfig = '''';
    gtk3.extraConfig = {
      gtk-xft-antialias=1;
      gtk-xft-hinting=1;
      gtk-xft-hintstyle="hintfull";
      gtk-xft-rgba="rgb";
      gtk-button-images=0;
      gtk-cursor-theme-size=0;
      gtk-enable-animations=false;
      gtk-enable-event-sounds=0;
      gtk-enable-input-feedback-sounds=0;
    };
    theme = {
      name = "cdetheme";
      package = pkgs.cde-gtk-theme;
    };
    iconTheme = {
      package = pkgs.paper-icon-theme;
      name = "Paper";
    };
  };
  xresources.properties = {
    "Emacs*font" = "Sudo-12";
    "Emacs*geometry" = "80x40";
    "Emacs.scrollBar" = "on";
    "Emacs.scrollBarWidth" =  6;
  };
  xsession = {
    enable = true;
    windowManager.command = "~/.stumpwm.d/start.sh";
  };
  programs.keychain.enable = true;
  programs.keychain.enableXsessionIntegration = true;
  programs.keychain.enableBashIntegration = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
  services.cbatticon.enable = onLocal;
  services.emacs.enable = onLocal;
  services.keynav.enable = onLocal;
  services.network-manager-applet.enable = onLocal;
  services.pasystray.enable = onLocal;
  services.dunst.enable = onLocal;
  services.picom.enable = true;
  services.dunst.settings = {
    global = {
      frame_color = "#959DCB";
      separator_color = "#959DCB";
    };
    urgency_low = {
      background = "#444267";
      foreground = "#676E95";
    };
    urgency_normal = {
      background = "#32374D";
      foreground = "#959DCB";
    };
    urgency_critical = {
      background = "#F07178";
      foreground = "#959DCB";
    };
    global.font = "Sudo 12";
    global.alignment = "left";
    global.geometry = "300x5-30+20";
    urgency_low.timeout = 10;
    urgency_normal.timeout = 10;
    urgency_critical.timeout = 10;
  };
  services.picom.package = pkgs.nur.repos.reedrw.picom-next-ibhagwan;
  services.picom.experimentalBackends = true;
  services.picom.backend = "glx";
  services.picom.opacityRule = [
      "80:class_g  = 'Dunst'"
  ];
  services.picom.extraOptions = ''
    detect-client-opacity = false;
    detect-rounded-corners = true;
    blur:
    {
        method = "kawase";
        strength = 2;
        background = false;
        background-frame = false;
        background-fixed = false;
    };
    blur-background-exclude = [
        "class_g = 'keynav'"
    ];
    corner-radius = 4;
    rounded-corners-exclude = [
        "window_type = 'dock'",
        "_NET_WM_STATE@:32a *= '_NET_WM_STATE_FULLSCREEN'",
        "class_g = 'keynav'",
    ];
    round-borders = 1;
    round-borders-exclude = [
        "class_g = 'keynav'"
    ];
  '';
  services.random-background = {
    enable = onLocal;
    imageDirectory = "%h/.config/wp";
  };
  home.file = {
    ".ideavimrc".source = ~/.config/ideavimrc;
    ".inputrc".source = ~/.config/inputrc;
    ".npmrc".source = ~/.config/npmrc;
    ".ratpoisonrc".source = ~/.config/ratpoisonrc;
    ".sbclrc".source = ~/.config/sbclrc;
    ".shrc".source = ~/.config/shrc;
  };
  services.gammastep =  {
    enable = true;
    longitude = -55.89;
    latitude = -27.36;
  };
  accounts.email = {
    maildirBasePath = "${config.home.homeDirectory}/Maildir";
  };
  home.file.".local/bin/vi"= {
    executable = true;
    text = ''
       #!/bin/sh
       exec emacs -Q -nw -l "${../mini-init.el}" "$@"
    '' ;
  };
  home.sessionPath = [
    ".local/bin"
  ];
 }
