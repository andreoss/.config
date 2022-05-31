{config, pkgs, lib, fetchurl, stdenv, ... }:
let
  python3Plus = pkgs.python3.withPackages
    (ps: with ps; [ pep8 ipython pandas pip meson seaborn pyqt5 tkinter ]);
  python2Plus = pkgs.python27.withPackages
    (ps: with ps; [ pep8 pip ]);
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
    android-tools
    eclipse-mat
    gradle
    groovy
    jetbrains.idea-community
    kotlin
    lombok
    maven
    nailgun
    netbeans
    umlet
    uncrustify
    visualvm
  ];
  clojurePackages = with pkgs; [ babashka leiningen clojure ];
  scalaPackages = with pkgs; [
    metals
    mill
    nailgun
    dotty
  ];
  fontPackages = with pkgs; [
    paratype-pt-mono
    uw-ttyp0
    terminus_font_ttf
    gentium
    unifont
    sudo-font
    dina-font
  ];
  my = {
    lang.perl.enable = true;
    lang.perl.packages = pkgs.perl532Packages;
    lang.clojure.enable = true;
    lang.cpp.enable = true;
    lang.go.enable = true;
    lang.java.enable = true;
    lang.lisp.enable = true;
    lang.ruby.enable = false;
    lang.ruby.packages = with pkgs; [ ruby gem ];
    lang.scala.enable = true;
    lang.tex.enable = true;
    desktop = true;
    wayland = false;
    x11 = true;
  };
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
    enable = my.lang.java.enable;
    enableLombok = true;
    package = pkgs.eclipses.eclipse-jee;
    plugins = with pkgs.eclipses.plugins; [
      vrapper
      spotbugs
      color-theme
      cdt
      jsonedit
      drools
      jdt-codemining
    ];
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
    enable = my.x11;
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
      "background" = "rgba:0000/0000/0200/c800";
      "color0" = "#000000"; # Color: Black        ~ 0
      "color10" = "#EBFFEB"; # Color: BrightGreen  ~ 10
      "color11" = "#EDEEA5"; # Color: BrightYellow ~ 11
      "color12" = "#EBFFFF"; # Color: BrightBlue   ~ 12
      "color13" = "#A1EEED"; # Color: BrightCyan   ~ 14
      "color14" = "#96D197"; # Color: MidGreen     ~ 13
      "color15" = "#FFFFEB"; # Color: BrightWhite  ~ 15
      "color1" = "#AD4F4F"; # Color: Red          ~ 1
      "color2" = "#468747"; # Color: Green        ~ 2
      "color3" = "#8F7734"; # Color: Yellow       ~ 3
      "color4" = "#268BD2"; # Color: Blue         ~ 4
      "color5" = "#888ACA"; # Color: Magenta      ~ 5
      "color6" = "#6AA7A8"; # Color: Cyan         ~ 6
      "color7" = "#F3F3D3"; # Color: White        ~ 7
      "color8" = "#878781"; # Color: BrightBlack  ~ 8
      "color9" = "#FFDDDD"; # Color: BrightRed    ~ 9
      "cursorBlink" = "true";
      "cursorColor" = "#AFBFBF";
      "depth" = 32;
      "foreground" = "#f3f3d3";
      "internalBorder" = 24;
      "keysym.C-0" = "resize-font:reset";
      "keysym.C-equal" = "resize-font:bigger";
      "keysym.C-minus" = "resize-font:smaller";
      "keysym.C-question" = "resize-font:show";
      "keysym.M-f" = "perl:keyboard-select:search";
      "keysym.M-s" = "perl:keyboard-select:activate";
      "keysym.M-u" = "perl:url-select:select_next";
      "letterSpace" = -1;
      "loginShell" = "true";
      "perl-lib" = "${pkgs.rxvt-unicode}/lib/urxvt/perl/";
      "secondaryScroll" = "true";
      "perl-ext-common" = "selection-to-clipboard,url-select,resize-font,keyboard-select";
      "urgentOnBell" = "true";
      "url-select.underline" = "true";
    };
  };
  programs.emacs = {
    overrides = self: super: rec { };
    enable = true;
    package = (pkgs.emacs.override {
      withToolkitScrollBars = false;
    }).overrideAttrs (attrs: {
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
      epkgs.go-imports
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
      alias = ''!f() { git config --get-regexp "^alias.''${1}$" ;}; f'';
      au = "add -u";
      branch = "branch --sort=-committerdate";
      cc = "clone";
      ci = "commit";
      cn = "!f() { git checkout -b \${1} origin/master ; }; f";
      co = "checkout";
      fa = "fetch --all";
      fe = "fetch";
      last = "log -1 HEAD";
      ll = "log --oneline";
      l = "log --graph --oneline --abbrev-commit --decorate=short";
      me = "merge";
      pu = "pull";
      pure = "pull --rebase";
      ri = "rebase --interactive";
      spull = "!git stash && git pull && git stash pop";
      st = "status";
      unstage = "reset HEAD -- ";
      xx = "reset HEAD";
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
    package = pkgs.chromium;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm"
      "dbepggeogbaibhgnhhndojpepiihcmeb"
      "gcbommkclmclpchllfjekcdonpmejbdp"
      "ghniladkapjacfajiooekgkfopkjblpn"
      "haiffjcadagjlijoggckpgfnoeiflnem"
      "ldpochfccmkkmhdbclfhpagapcfdljkj"
      "naepdomgkenhinolocfifgehidddafch"
      "oomoeacogjkolheacgdkkkhbjipaomkn"
    ];
  };
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      browserpass
      bukubrow
      tridactyl
      ublock-origin
      umatrix
    ];
    profiles."default" = {
      id = 0;
      extraConfig = builtins.readFile (builtins.fetchurl
        "https://raw.githubusercontent.com/arkenfox/user.js/master/user.js");
      # userChrome = (builtins.readFile (builtins.fetchurl
      #   ("https://raw.githubusercontent.com/dannycolin/fx-compact-mode/main/userChrome.css")));
      userContent = "";
      settings = {
        "accessibility.force_disabled" = 1;
        "browser.bookmarks.autoExportHTML" = true;
        "browser.bookmarks.file" = builtins.toString ~/.config/bookmarks.html;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.cache.disk.enable" = false;
        "browser.cache.offline.enable" = false;
        "browser.link.open_newwindow" = 2;
        "browser.places.importBookmarksHTML" = true;
        "browser.privatebrowsing.autostart" = true;
        "browser.search.searchEnginesURL" = "";
        "browser.startup.homepage" = "about:blank";
        "browser.tabs.tabMinWidth" = 16;
        "browser.uidensity" = 1;
        "devtools.application.enabled" = false;
        "devtools.debugger.enabled" = false;
        "devtools.inspector.enabled" = false;
        "devtools.performance.enabled" = false;
        "devtools.styleeditor.enabled" = false;
        "extensions.abuseReport.enabled" = false;
        "extensions.pocket.enabled" = false;
        "extensions.update.autoUpdateDefault" = false;
        "extensions.update.enabled" = false;
        "full-screen-api.ignore-widgets" = true;
        "pdfjs.disabled" = true;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.siteSettings" = true;
        "privacy.cpd.offlineApps" = true;
        "privacy.cpd.passwords" = true;
        "privacy.cpd.siteSettings" = true;
        "signon.rememberSignons" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
    };
  };
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.keyboard.layout = "us,ru";
  home.keyboard.options =
    [ "eurosign:e" "ctrl:nocaps,grp:shifts_toggle" "compose:ralt" ];
  home.stateVersion = "22.05";
  home.sessionPath = [ "$HOME/.local/bin" ];
  home.activation.installJdks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm --recursive --force "$HOME/.jdk/"
    install --directory --mode 755 --owner="$USER" "$HOME/.jdk/"
    ln --symbolic --force "${pkgs.adoptopenjdk-hotspot-bin-8.out}"  $HOME/.jdk/8
    ln --symbolic --force "${pkgs.adoptopenjdk-hotspot-bin-11.out}" $HOME/.jdk/11
    ln --symbolic --force "${pkgs.adoptopenjdk-hotspot-bin-16.out}" $HOME/.jdk/16
    ln --symbolic --force "${pkgs.openjdk17.out}/lib/openjdk"       $HOME/.jdk/17
    ln --symbolic --force "${pkgs.graalvm11-ce.out}"                $HOME/.jdk/11g
    ln --symbolic --force "${pkgs.graalvm17-ce.out}"                $HOME/.jdk/17g
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
    NIX_SHELL_PRESERVE_PROMPT = 1;
    XKB_DEFAULT_LAYOUT = config.home.keyboard.layout;
    XKB_DEFAULT_OPTIONS =
      builtins.concatStringsSep "," config.home.keyboard.options;
    EDITOR = "vi";
    JDK_8 = "$HOME/.jdk/8";
    JDK_11 = "$HOME/.jdk/11";
    JDK_16 = "$HOME/.jdk/16";
    JDK_17 = "$HOME/.jdk/17";
    GVM_11 = "$HOME/.jdk/11g";
    GVM_17 = "$HOME/.jdk/17g";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # _JAVA_OPTIONS =
    #   "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Djdk.gtk.version=3";
    WLR_NO_HARDWARE_CURSORS = 1;
    MAVEN_OPTS =
      "-Djava.awt.headless=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS";
  };
  home.packages = with pkgs;
    [
      ack
      atool
      buku
      bukubrow
      cloc
      coreutils
      curl
      davmail
      docker
      entr
      file
      imagemagick7Big
      jwhois
      libressl
      lsof
      minikube
      mtr
      nix
      nixfmt
      nix-tree
      oathToolkit
      openshift
      openvpn
      paperkey
      pavucontrol
      psmisc
      pulsemixer
      python2Plus
      python3Plus
      qrencode
      ripgrep
      rnix-lsp
      screen
      sdcv
      shellcheck
      shfmt
      sysstat
      unar
      unzip
      wget
      zip
    ] ++ fontPackages
    ++ (lib.optionals (my.desktop) [ sway cage grim slurp wl-clipboard])
    ++ (lib.optionals (my.desktop) [ wmname xclip ])
    ++ [ yamllint xmlformat yaml2json json2yaml yaml-merge jo libxslt dos2unix ]
    ++ (lib.optionals (my.lang.perl.enable) (with my.lang.perl.packages; [
      ModernPerl
      Moose
      Appcpanminus
      PerlCritic
      PerlTidy
      PodTidy
      HTMLTidy
      BUtils
      Appperlbrew
      rakudo
      perl532
    ])) ++ (lib.optionals (my.desktop) [
      mpv
      ffmpeg-full
      aria
      python39Packages.youtube-dl
      python39Packages.yt-dlp
    ]) ++ (lib.optionals (my.desktop) [ signal-desktop ]) ++ [
      mercurialFull
      gitAndTools.git-codeowners
      gitAndTools.git-extras
      gitAndTools.gitflow
      git-crypt
      pre-commit
      aspell
      aspellDicts.ru
      aspellDicts.en
      aspellDicts.es
    ] ++ (lib.optionals (my.lang.cpp.enable) [
      autoconf
      binutils
      ccls
      clang-analyzer
      clang-tools
      cling
      cmake
      cppcheck
      gcc
      gdb
      gnumake
      indent
      ninja
      pkg-config
      valgrind
    ])
    ++ (lib.optionals (my.desktop) [ nyxt ])
    ++ (lib.optionals (my.lang.tex.enable) [
      mupdf
      zathura
      djview
      pandoc
      libertine
      abiword
      texlive.combined.scheme-full
    ])
    ++ (lib.optionals (my.lang.lisp.enable) sbclPackages)
    ++ (lib.optionals (my.lang.ruby.enable) my.lang.ruby.packages)
    ++ (lib.optionals (my.lang.java.enable) jdkRelatedPackages)
    ++ (lib.optionals (my.lang.go.enable) [gotools gocode])
    ++ (lib.optionals (my.lang.clojure.enable) clojurePackages)
    ++ (lib.optionals (my.lang.scala.enable) scalaPackages);
  fonts.fontconfig.enable = true;
  gtk = {
    font.package = pkgs.terminus_font_ttf;
    font.name = "Terminus 11";
    enable = true;
    gtk2.extraConfig = "";
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-xft-rgba = "rgb";
      gtk-fallback-icon-theme = "gnome";
      gtk-button-images = 0;
      gtk-cursor-theme-size = 0;
      gtk-enable-animations = false;
      gtk-enable-event-sounds = 0;
      gtk-enable-input-feedback-sounds = 0;
    };
  };
  xresources.properties = {
    "Emacs*toolBar" = 0;
    "Emacs*menuBar" = 0;
    "Emacs*geometry" = "80x30";
    "Emacs*font" = "Terminus";
    "Emacs*scrollBar" = "on";
    "Emacs*scrollBarWidth" = 6;
    "XTerm*faceName" = "dejavu sans mono";
    "XTerm*charClass" = [ "37:48" "45-47:48" "58:48" "64:48" "126:48" ];
  };
  xsession = {
    enable = my.x11;
    windowManager.command = "~/.stumpwm.d/start.sh";
  };
  programs.keychain.enable = true;
  programs.keychain.enableXsessionIntegration = my.x11;
  programs.keychain.enableBashIntegration = true;
  services.cbatticon.enable = my.x11;
  services.emacs.enable = true;
  services.keynav.enable = my.x11;
  services.network-manager-applet.enable = my.x11;
  services.pasystray.enable = my.x11;
  services.dunst.enable = my.x11;
  services.picom.enable = my.x11;
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
    global.font = "Terminus";
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
    enable = my.x11;
    imageDirectory = "%h/.config/wp";
  };
  home.file = {
    ".ideavimrc".source = ./../ideavimrc;
    ".inputrc".source = ./../inputrc;
    ".npmrc".source = ./../npmrc;
    ".ratpoisonrc".source = ./../ratpoisonrc;
    ".sbclrc".source = ./../sbclrc;
    ".indent.pro".source = ./../indent.pro;
    ".screenrc".source = ./../screenrc;
    ".local/bin/citrix".source = ./../scripts/citrix;
    ".local/share/JetBrains/consentOptions/accepted".text = "";
  };
  services.gammastep = {
    enable = my.x11;
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
  services.xcape.enable = my.x11;
  services.gpg-agent = {
    grabKeyboardAndMouse = true;
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryFlavor = "gnome3";
  };
  programs.notmuch = { enable = true; };
  services.mbsync.postExec = "notmuch new";
  services.mbsync.enable = false;
  programs.go.enable = true;
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "${../wp/1.jpeg}";
      picture-options = "centered";
    };
    "org/gnome/desktop/sound" = {
        event-sounds=false;
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = config.home.keyboard.options;
      sources = builtins.map (x: "('xkb', '${x}')") (lib.strings.splitString "," config.home.keyboard.layout);
    };
  };
  programs.sbt = {
    enable = true;
    package=  pkgs.sbt-with-scala-native;
    plugins = [];
  };
}
