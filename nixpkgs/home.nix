{ config, pkgs, lib, fetchurl, stdenv, ... }:
let
  hostname =
    builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile /etc/hostname);
  onHost = hosts: builtins.any (s: s == hostname) hosts;
  onLocal = onHost [ "thnk" "vtfn" ];
  whenOn = host: result: alternative:
    if (onHost host) then result else alternative;
  whenOnLocal = ((whenOn) [ "thnk" "vtfn" ]);
  python3Plus = pkgs.python3.withPackages (ps: with ps; [ pep8 ipython pandas pip meson seaborn pyqt5 tkinter ]);
  python2Plus = pkgs.python27.withPackages (ps: with ps; [ pep8 pip ]);
  sbclPackages = (with pkgs.lispPackages; [
    dbus
    external-program
    bordeaux-threads
    quicklisp
    swank
    stumpwm
  ]) ++ (with pkgs; [ roswell sbcl clisp ]);
  jdkRelatedPackages = with pkgs; [
    ant
    clojure
    eclipse-mat
    gradle
    groovy
    jetbrains.idea-community
    kotlin
    leiningen
    babashka
    lombok
    maven
    metals
    mill
    nailgun
    netbeans
    dotty
    sbt-with-scala-native
    spring-boot-cli
    umlet
    uncrustify
    visualvm
    ruby
    gem
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
in {
  nixpkgs.config = {
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball
        "https://github.com/nix-community/NUR/archive/master.tar.gz") {
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
    plugins = with pkgs.eclipses.plugins; [ vrapper spotbugs color-theme ];
  };
  programs.matplotlib.enable = true;
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    shortcut = "a";
  };
  programs.urxvt = {
    enable = true;
    package = pkgs.rxvt_unicode-with-plugins;
    iso14755 = true;
    fonts = [ "xft:Ttyp0:size=10" ];
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
      "perl-ext-common" =
        "selection-to-clipboard,url-select,resize-font,keyboard-select";
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
      "cursorColor" = "#AFBFBF";
      "cursorBlink" = "true";
      "internalBorder" = 24;
      "depth" = 32;
      "background" = "rgba:0000/0000/0200/c800";
      "foreground" = "#aeaeae";
      "color0" = "#101010";
      "color8" = "#353535";
      "color1" = "#AE0050";
      "color9" = "#FA3A99";
      "color2" = "#69AE11";
      "color10" = "#44FA80";
      "color3" = "#C47F2C";
      "color11" = "#FABE9A";
      "color4" = "#4040AE";
      "color12" = "#4F4FEA";
      "color5" = "#7E43AE";
      "color13" = "#AB88DE";
      "color6" = "#4979AE";
      "color14" = "#4EB9FA";
      "color7" = "#A999AE";
      "color15" = "#D3D0D0";
    };
  };
  programs.emacs = {
    overrides = self: super: rec { };
    enable = true;
    package = (pkgs.emacs.override {
      withGTK3 = false;
      withGTK2 = false;
      srcRepo = false;
    }).overrideAttrs (attrs: {
      configureFlags = [
        "--disable-build-details"
        "--with-cairo"
        "--with-modules"
        "--with-nativecomp"
        "--without-toolkit-scroll-bars"
        "--with-xft"
        "--with-x-toolkit=athena"
      ];
    });
    extraPackages = epkgs: [
      epkgs.exwm
      epkgs.elpher
      epkgs.elfeed
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
  programs.feh.enable = true;
  programs.man.enable = true;
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    delta.enable = true;
    userName = "andreoss";
    userEmail = "andreoss@sdf.org";
    signing = {
      key = "2DB39B412CDF97C7";
      signByDefault = true;
    };
    extraConfig = { init = { defaultBranch = "master"; }; };
    aliases = {
      fe = "fetch";
      fa = "fetch --all";
      au = "add -u";
      cc = "clone";
      ci = "commit";
      co = "checkout";
      st = "status";
      ll = "log --oneline";
      l = "log --graph --oneline --abbrev-commit --decorate=short";
      me = "merge";
      pu = "pull";
      pure = "pull --rebase";
      ri = "rebase --interactive";
      xx = "reset HEAD";
      cn = "!f() { git checkout -b \${1} origin/master ; }; f";
      last = "log -1 HEAD";
      unstage = "reset HEAD -- ";
      alias = ''!f() { git config --get-regexp "^alias.''${1}$" ;}; f'';
      branch = "branch --sort=-committerdate";
      spull = "!git stash && git pull && git stash pop";
    };
    extraConfig = {
      pull.rebase = true;
      rebase.autosquash = true;
      rerere.enabled = true;
    };
  };
  programs.browserpass = {
    enable = true;
    browsers = [ "chromium" "firefox" ];
  };
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm"
      "gcbommkclmclpchllfjekcdonpmejbdp"
      "haiffjcadagjlijoggckpgfnoeiflnem"
      "dbepggeogbaibhgnhhndojpepiihcmeb"
      "ldpochfccmkkmhdbclfhpagapcfdljkj"
    ];
  };
  programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      https-everywhere
      tridactyl
      ublock-origin
      umatrix
      browserpass
    ];
    profiles."default" = {
      id = 0;
      extraConfig = builtins.readFile (builtins.fetchurl
        "https://raw.githubusercontent.com/arkenfox/user.js/master/user.js");
      userChrome = (builtins.readFile (builtins.fetchurl
        ("https://raw.githubusercontent.com/dannycolin/fx-compact-mode/main/userChrome.css")));
      userContent = "";
      settings = {
        "extensions.pocket.enabled" = false;
        # Extensions are managed with Nix, don't auto update anything
        "extensions.update.autoUpdateDefault" = false;
        "extensions.update.enabled" = false;
        "signon.rememberSignons" = false;
        "browser.privatebrowsing.autostart" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.tabs.tabMinWidth" = 16;
        "browser.uidensity" = 1;
        "browser.startup.homepage" = "about:blank";
        "browser.places.importBookmarksHTML" = true;
        "browser.bookmarks.file" = builtins.toString ~/.config/bookmarks.html;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.bookmarks.autoExportHTML" = true;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.siteSettings" = true;
        "privacy.cpd.offlineApps" = true;
        "privacy.cpd.passwords" = true;
        "privacy.cpd.siteSettings" = true;
        "browser.cache.disk.enable" = false;
        "browser.cache.offline.enable" = false;
        "browser.search.searchEnginesURL" = "";
      };
    };
  };
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.keyboard.layout = "us,ru";
  home.keyboard.options =
    [ "eurosign:e" "ctrl:nocaps,grp:shifts_toggle" "compose:ralt" ];
  home.stateVersion = "21.11";
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.activation.installJdks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm --recursive --force "$HOME/.jdk/"
    install --directory --mode 755 --owner="$USER" "$HOME/.jdk/"
    ln --symbolic --force "${pkgs.adoptopenjdk-hotspot-bin-8.out}"  $HOME/.jdk/8
    ln --symbolic --force "${pkgs.adoptopenjdk-hotspot-bin-11.out}" $HOME/.jdk/11
    ln --symbolic --force "${pkgs.adoptopenjdk-hotspot-bin-16.out}" $HOME/.jdk/16
    ln --symbolic --force "${pkgs.openjdk17.out}/lib/openjdk"       $HOME/.jdk/17
    ln --symbolic --force "${pkgs.jdk17_headless.out}/lib/openjdk"  $HOME/.jdk/17-headless
    ln --symbolic --force "${pkgs.graalvm11-ce.out}"                $HOME/.jdk/11-graal
  '';
  home.activation.installFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
    enable = true;
    enableVteIntegration = true;
    initExtra = builtins.readFile ~/.config/shrc;
  };
  programs.gpg.enable = true;
  programs.password-store = {
    enable = true;
    package =
      pkgs.pass.withExtensions (exts: [ exts.pass-otp exts.pass-import ]);
  };
  home.sessionVariables = {
    XKB_DEFAULT_LAYOUT = config.home.keyboard.layout;
    XKB_DEFAULT_OPTIONS =
    JDK_8 = "$HOME/.jdk/8";
    JDK_11 = "$HOME/.jdk/11";
    JDK_16 = "$HOME/.jdk/16";
    JDK_17 = "$HOME/.jdk/17";
    JDK_17H = "$HOME/.jdk/17-headless";
    GRAALVM_11 = "$HOME/.jdk/11-graal";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    _JAVA_OPTIONS =
      "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Djdk.gtk.version=3";
    WLR_NO_HARDWARE_CURSORS = 1;
    MAVEN_OPTS =
      "-Djava.awt.headless=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS";
  };
  home.packages = with pkgs;
    [
      ack
      atool
      screen
      cloc
      coreutils
      davmail
      docker
      file
      imagemagick7Big
      lsof
      mtr
      sysstat
      nix
      nix-tree
      nixfmt
      rnix-lsp
      openshift
      minikube
      openvpn
      pavucontrol
      pulsemixer
      ripgrep
      sdcv
      shellcheck
      shfmt
      zip
      unzip
      unar
      wget
      curl
      libressl
      libqrencode
      paperkey
      xclip
      wmname
      python3Plus
    ]
    ++ fontPackages
    ++ [ yamllint xmlformat yaml2json json2yaml yaml-merge jo libxslt ]
    ++ (whenOnLocal (with perl532Packages; [
      Appcpanminus
      PerlCritic
      PerlTidy
      PodTidy
      HTMLTidy
      BUtils
      Appperlbrew
      rakudo
    ]) [ ])
    ++ [pkg-config roswell sbcl clisp]
    ++ (whenOnLocal [ mpv ffmpeg-full aria python39Packages.youtube-dl ] [ ])
    ++ (whenOnLocal [ signal-desktop ] [ ])
    ++ [ aspell aspellDicts.ru aspellDicts.en aspellDicts.es ] ++ [
      mercurialFull
      gitAndTools.git-codeowners
      gitAndTools.git-extras
      gitAndTools.gitflow
      git-crypt
      pre-commit
    ] ++ [
      gnumake
      cmake
      gcc
      cppcheck
      clang-analyzer
      valgrind
      indent
      binutils
      autoconf
      ccls
    ]
    ++ (whenOnLocal [ pandoc libertine texlive.combined.scheme-full ] [ ])
    ++ (whenOnLocal [ nyxt ] [ ])
    ++ (whenOnLocal sbclPackages [ ])
    ++ jdkRelatedPackages
    ++ (whenOnLocal [android-tools] []);
  fonts.fontconfig.enable = true;
  gtk = {
    font.package = pkgs.paratype-pt-mono;
    font.name = "PT Mono 11";
    enable = true;
    gtk2.extraConfig = "";
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-xft-rgba = "rgb";
      gtk-button-images = 0;
      gtk-cursor-theme-size = 0;
      gtk-enable-animations = false;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
    };
    theme = {
      package = pkgs.onestepback;
      name = "OneStepBack";
    };
    iconTheme = {
      package = pkgs.tela-icon-theme;
      name = "Tela";
    };
  };
  xresources.properties = {
    "Emacs*toolBar" = 0;
    "Emacs*menuBar" = 0;
    "Emacs*geometry" = "80x30";
    "Emacs*font" = "PT Mono";
    "Emacs*scrollBar" = "on";
    "Emacs*scrollBarWidth" = 6;
    "XTerm*faceName" = "dejavu sans mono";
    "XTerm*charClass" = [ "37:48" "45-47:48" "58:48" "64:48" "126:48" ];
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
      background = "#181818";
      foreground = "#EAEAEA";
    };
    urgency_normal = {
      background = "#581818";
      foreground = "#eaeaea";
    };
    urgency_critical = {
      background = "#F07178";
      foreground = "#959DCB";
    };
    global.font = "PT Mono";
    global.alignment = "right";
    global.word_warp = "true";
    global.line_height = 3;
    global.geometry = "384x5-30+20";
    urgency_low.timeout = 10;
    urgency_normal.timeout = 10;
    urgency_critical.timeout = 10;
  };
  services.picom.package = pkgs.nur.repos.reedrw.picom-next-ibhagwan;
  services.picom.experimentalBackends = true;
  services.picom.backend = "glx";
  services.picom.opacityRule = [ "50:class_g  = 'Dunst'" ];
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
    corner-radius = 1;
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
    ".indent.pro".source = ~/.config/indent.pro;
    ".screenrc".source = ~/.config/screenrc;
  };
  services.gammastep = {
    enable = true;
    longitude = -55.89;
    latitude = -27.36;
  };
  home.file.".local/bin/nano" = {
    executable = true;
    text = ''
      #!/bin/sh
      exit 1
    '';
  };
  home.file.".local/bin/vi" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec emacs --quick --no-window-system --load="${../mini-init.el}" "$@"
    '';
  };
  home.file.".local/bin/mozilla" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec firefox "$@"
    '';
  };
  home.file.".local/bin/jetbrains" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec firejail --profile="${../firejail/idea.profile}" idea-community "$@"
    '';
  };
  home.file.".local/bin/citrix" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec firejail wfica "$@"
    '';
  };
  home.file.".local/bin/xterm" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec urxvt "$@"
    '';
  };
  home.file.".local/bin/xscreen" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec xterm -e screen -D -R -S "$\{1:-primary}" "$*"
    '';
  };
  home.file.".local/bin/mpa" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec mpv --vo=null "$@"
    '';
  };
  accounts.email = {
    maildirBasePath = "${config.home.homeDirectory}/Maildir";
  };
  accounts.email.accounts = (import ./mail.nix);
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
  };
  services.mbsync.postExec = "notmuch new";
  services.mbsync.enable = true;
}
