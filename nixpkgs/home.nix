{ config, pkgs, lib, stdenv, ... }:
let
  python3Plus = pkgs.python3.withPackages
    (ps: with ps; [ pep8 ipython pandas pip meson seaborn pyqt5 tkinter ]);
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
    android-tools
    ant
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
  scalaPackages = with pkgs; [ metals mill nailgun dotty ];
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
    desktop = true;
    lang.clojure.enable = true;
    lang.cpp.enable = true;
    lang.go.enable = true;
    lang.java.enable = true;
    lang.lisp.enable = true;
    lang.office.enable = true;
    lang.perl.enable = true;
    lang.perl.packages = pkgs.perl536Packages;
    lang.ruby.enable = false;
    lang.ruby.packages = with pkgs; [ ruby gem ];
    lang.rust.enable = true;
    lang.rust.packages = with pkgs; [
      rust-analyzer
      rustup
    ];
    lang.scala.enable = true;
    lang.tex.enable = true;
    x11 = true;
  };
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    abiVersions = [ "armeabi-v7a" "arm64-v8a" "x86_64" ];
    buildToolsVersions = [ "26.0.1" "31.0.0" ];
    cmakeVersions = [ "3.10.2" ];
    emulatorVersion = "30.3.4";
    includeEmulator = false;
    includeNDK = true;
    includeSources = false;
    includeSystemImages = false;
    ndkVersions = [ "21.1.6352462" ];
    platformVersions = [ "29" "31" ];
    toolsVersion = "26.0.1";
  };
in {
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url =
        "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
    }))
  ];
  nixpkgs.config = {
    android_sdk.accept_license = true;
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball {
        url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
      }) { inherit pkgs; };
    };
  };
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.lf.enable = true;
  programs.jq.enable = true;
  programs.eclipse = {
    enable = my.lang.java.enable;
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
          url = "https://github.com/IntelliJIdeaKeymap4Eclipse/IntelliJIdeaKeymap4Eclipse-update-site/archive/refs/heads/main.zip";
          sha256 = "sha256-L43JWpYy/9JvOLi9t+UioT/uQbBLL08pgHrW8SuGQ8M=";
        };
      })
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
    enable = true;
    package = pkgs.rxvt_unicode-with-plugins;
    iso14755 = true;
    fonts = [ "-xos4-*-*-*-*-*-32-*-*-*-*-*-*-*" ];
    scroll = {
      bar = {
        enable = true;
        style = "plain";
      };
      lines = 10000000;
      scrollOnOutput = false;
      scrollOnKeystroke = true;
    };
    extraConfig = {
      "context.names" = "sudo,ssh,python,gdb,java";
      "context.sudo.background" = "[90]#8F0000";
      "context.ssh.background " = "[90]#28488A";
      "context.python.background" = "[90]#245488";
      "context.gdb.background" = "[90]#236823";
      "context.java.background" = "[90]#28381A";
      "background" = "[80]#000000";
      "color0" = "[90]#000000"; # Color: Black        ~ 0
      "color1" = "#AA1F1F"; # Color: Red          ~ 1
      "color2" = "#468747"; # Color: Green        ~ 2
      "color3" = "#8F7734"; # Color: Yellow       ~ 3
      "color4" = "#568BD2"; # Color: Blue         ~ 4
      "color5" = "#888ACA"; # Color: Magenta      ~ 5
      "color6" = "#6AA7A8"; # Color: Cyan         ~ 6
      "color7" = "#F3F3D3"; # Color: White        ~ 7
      "color8" = "#878781"; # Color: BrightBlack  ~ 8
      "color9" = "#FFADAD"; # Color: BrightRed    ~ 9
      "color10" = "#EBFFEB"; # Color: BrightGreen  ~ 10
      "color11" = "#EDEEA5"; # Color: BrightYellow ~ 11
      "color12" = "#EBFFFF"; # Color: BrightBlue   ~ 12
      "color13" = "#A1EEED"; # Color: BrightCyan   ~ 14
      "color14" = "#96D197"; # Color: MidGreen     ~ 13
      "color15" = "#FFFFEB"; # Color: BrightWhite  ~ 15
      "cursorBlink" = "true";
      "cursorColor" = "#AFBFBF";
      "internalBorder" = 16;
      "depth" = 32;
      "foreground" = "#F3F3D3";
      "keysym.C-0" = "resize-font:reset";
      "keysym.C-equal" = "resize-font:bigger";
      "keysym.C-minus" = "resize-font:smaller";
      "keysym.C-question" = "resize-font:show";
      "keysym.M-f" = "perl:keyboard-select:search";
      "keysym.M-s" = "perl:keyboard-select:activate";
      "keysym.M-u" = "perl:url-select:select_next";
      "letterSpace" = -1;
      "loginShell" = "true";
      "perl-ext-common" =
        "context,selection-to-clipboard,url-select,resize-font,keyboard-select";
      "perl-lib" = "${pkgs.rxvt-unicode}/lib/urxvt/perl/";
      "secondaryScroll" = "true";
      "urgentOnBell" = "true";
      "url-select.underline" = "true";
    };
  };
  programs.emacs = {
    enable = true;
    package = pkgs.emacs.override {
      withToolkitScrollBars = false;
      withAthena = true;
      nativeComp = true;
    };
    extraPackages = elpa: with elpa; [
      elfeed
      elpher
      evil
      evil-collection
      exwm
      forge
      go-imports
      magit
      pdf-tools
      telega
      vterm
      xenops
    ];
  };
  programs.feh.enable = true;
  programs.man.enable = true;
  programs.info.enable = true;
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
    includes = [{
      path = ../git/config.work;
      condition = "gitdir:~/work";
    }];
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
    package = pkgs.wrapFirefox pkgs.firefox-esr-unwrapped {
      forceWayland = false;
      extraPolicies = {
        NoDefaultBookmarks = true;
        DisableBuiltinPDFViewer = true;
        PDFjs = {
          Enabled = false;
        };
        Permissions = {
          Locked = true;
        };
        PictureInPicture = {
          Enabled = false;
          Locked = true;
        };
        DisableFeedbackCommands= true ;
        DisableFirefoxAccounts= true ;
        DisableFirefoxScreenshots= true ;
        DisableFirefoxStudies= true ;
        DisableForgetButton= true ;
        DisableFormHistory= true ;
        DisableMasterPasswordCreation= true ;
        DisablePasswordReveal= true ;
        DisablePocket = true;
        DisablePrivateBrowsing = true;
        DisableProfileImport= true ;
        DisableProfileRefresh= true ;
        DisableSafeMode= true ;
        DisableSetDesktopBackground= true ;
        DisableSystemAddonUpdate= true ;
        DisableTelemetry = true;
        CaptivePortal = false;
        ManagedBookmarks = [];
        Bookmarks = [];
        "Extensions"= {
          "Install"= [
            "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin"
            "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim"
            "https://addons.mozilla.org/firefox/downloads/latest/umatrix"
            "https://addons.mozilla.org/firefox/downloads/latest/browserpass-ce"
            "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes"
          ];
        };
        ExtensionSettings = {
          "*" = {
            installation_mode = "force_installed";
          };
        };
        NetworkPrediction = false;
        NewTabPage = false;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        SanitizeOnShutdown = true;
        SearchEngines =  {
          Default = "DuckDuckGo";
          Remove = [ "Google" "Bing" "Amazon.com" ];
          Add =  [
            {
              "Name" =  "Invidious";
              "Description" =  "Search for videos, channels, and playlists on Invidious";
              "URLTemplate" =  "https://invidious.snopyta.org/search?q={searchTerms}";
              "Method" =  "GET";
              "IconURL" =  "https://invidious.snopyta.org/favicon.ico";
              "Alias" =  "invidious";
            }
            {
              "Name" =  "GitHub";
              "Description" =  "Search GitHub";
              "URLTemplate" =  "https://github.com/search?q={searchTerms}";
              "Method" =  "GET";
              "IconURL" =  "https://github.com/favicon.ico";
              "Alias" =  "github";
            }
            {
              "Name" =  "Wikipedia (es)";
              "Description" =  "Wikipedia (es)";
              "URLTemplate" =  "https://es.wikipedia.org/w/api.php?action=opensearch&amp;format=xml&amp;search={searchTerms}&amp;namespace=100|104|0";
              "Method" =  "GET";
              "IconURL" =  "https://es.wikipedia.org/static/favicon/wikipedia.ico";
              "Alias" =  "wikipedia-es";
            }
            {
              "Name" =  "NixOS options";
              "Description" =  "Search NixOS options by name or description.";
              "URLTemplate" =  "https://search.nixos.org/options?query={searchTerms}";
              "Method" =  "GET";
              "IconURL" =  "https://nixos.org/favicon.png";
              "Alias" =  "nixos-options";
            }
            {
              "Name" =  "NixOS packages";
              "Description" =  "Search NixOS options by name or description.";
              "URLTemplate" =  "https://search.nixos.org/packages?query={searchTerms}";
              "Method" =  "GET";
              "IconURL" =  "https://nixos.org/favicon.png";
              "Alias" =  "nixos-packages";
            }
          ];
        };
      };
    };
    profiles."default" = {
      id = 0;
      extraConfig = builtins.readFile (builtins.fetchurl
        "https://raw.githubusercontent.com/arkenfox/user.js/master/user.js");
      settings = {
        "accessibility.force_disabled" = 1;
        "browser.bookmarks.autoExportHTML" = false;
        "browser.places.importBookmarksHTML" = true;
        "browser.bookmarks.file" = builtins.toString ../bookmarks.html;
        "browser.bookmarks.restore_default_bookmarks" = true;
        "browser.cache.disk.enable" = false;
        "browser.cache.offline.enable" = false;
        "browser.link.open_newwindow" = 2;
        "browser.privatebrowsing.autostart" = true;
        "browser.search.searchEnginesURL" = "";
        "browser.startup.homepage" = "about:blank";
        "browser.tabs.tabMinWidth" = 16;
        "browser.uidensity" = 1;
        "extensions.abuseReport.enabled" = false;
        "full-screen-api.ignore-widgets" = true;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.siteSettings" = true;
        "privacy.cpd.offlineApps" = true;
        "privacy.cpd.passwords" = true;
        "privacy.cpd.siteSettings" = true;
        "signon.rememberSignons" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "font.default.x-western" = "Terminus";
        "font.name.monospace.x-western" = "Terminus";
        "font.name.sans-serif.x-western" = "Terminus";
        "font.name.serif.x-western" = "Terminus";
      };
    };
  };
  home.enableNixpkgsReleaseCheck = true;
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
  programs.ssh = { enable = true; };
  programs.keychain = {
    enable = true;
    enableXsessionIntegration = my.x11;
    enableBashIntegration = true;
  };
  programs.gpg.enable = true;
  programs.password-store = {
    enable = true;
    package =
      pkgs.pass.withExtensions (exts: [ exts.pass-otp exts.pass-import ]);
  };
  home.sessionVariables = {
    # ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
    # ANDROID_NDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk/ndk-bundle";
    NIX_SHELL_PRESERVE_PROMPT = 1;
    XKB_DEFAULT_LAYOUT = config.home.keyboard.layout;
    XKB_DEFAULT_OPTIONS =
      builtins.concatStringsSep "," config.home.keyboard.options;
    EDITOR = "vi";
    JDK_8 = "$HOME/.jdk/8";
    JDK_11 = "$HOME/.jdk/11";
    JDK_16 = "$HOME/.jdk/16";
    JDK_17 = "$HOME/.jdk/17";
    GVM_11 = "$HOME/.jdk/11-graal";
    GVM_17 = "$HOME/.jdk/17-graal";
    GRAALVM_HOME = "$HOME/.jdk/17-graal";
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
      silver-searcher
      atool
      buku
      bukubrow
      cloc
      coreutils
      curl
      docker
      dockfmt
      entr
      file
      imagemagick7Big
      jwhois
      libressl
      lsof
      minikube
      mtr
      nvi
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
      ascii
      rnix-lsp
      screen
      sdcv
      shellcheck
      shfmt
      sysstat
      unar
      unzip
      wget
      pv
      rsync
      dig.dnsutils
      zip
    ] ++ fontPackages
    ++ (lib.optionals (my.desktop) [ wmname xclip xorg.xkill rox-filer ])
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
      perl536
    ])) ++ (lib.optionals (my.desktop) [
      aria
      ffmpeg-full
      mpc_cli
      python39Packages.youtube-dl
      python39Packages.yt-dlp
    ]) ++ (lib.optionals (my.desktop) [ signal-desktop ]) ++ [
      fossil
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
      cpplint
      gcc
      gdb
      strace
      gnumake
      automake
      lcov
      indent
      ninja
      pkg-config
      valgrind
      tinycc
    ])
    ++ (lib.optionals (my.lang.tex.enable) [
      zathura
      djview
      pandoc
      libertine
      texlive.combined.scheme-full
    ]) ++ (lib.optionals (my.lang.office.enable) [
      libreoffice-fresh
      abiword
      freerdp
      davmail
    ]) ++ (lib.optionals (my.lang.lisp.enable) sbclPackages)
    ++ (lib.optionals (my.lang.ruby.enable) my.lang.ruby.packages)
    ++ (lib.optionals (my.lang.rust.enable) my.lang.rust.packages)
    ++ (lib.optionals (my.lang.java.enable) jdkRelatedPackages)
    ++ (lib.optionals (my.lang.go.enable) [ gotools gocode ])
    ++ (lib.optionals (my.lang.clojure.enable) clojurePackages)
    ++ (lib.optionals (my.lang.scala.enable) scalaPackages);
  fonts.fontconfig.enable = true;
  gtk = {
    font.package = pkgs.terminus_font_ttf;
    font.name = "Terminus 9";
    enable = true;
    iconTheme.name = "Adwaita";
    iconTheme.package = pkgs.gnome.adwaita-icon-theme;
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
    gtk3.bookmarks = [
      "file://${config.home.homeDirectory}/Books/"
      "file://${config.home.homeDirectory}/Work/"
      "file://${config.home.homeDirectory}/Documents/"
    ];
  };
  xresources.properties = {
    "Emacs*toolBar" = 0;
    "Emacs*menuBar" = 0;
    "Emacs*geometry" = "80x30";
    "Emacs*font" = "-Xos4-Terminus-bold-normal-normal-*-32-*-*-*-m-*-iso10646-1";
    "Emacs*scrollBar" = "on";
    "Emacs*scrollBarWidth" = 6;
    "XTerm*charClass" = [ "37:48" "45-47:48" "58:48" "64:48" "126:48" ];
  };
  xsession = {
    enable = true;
    scriptPath = ".xsession";
    windowManager.command = ''
      ${pkgs.feh}/bin/feh --no-fehbg --bg-center ${../wp/1.jpeg}
      ${pkgs._9menu}/bin/9menu                   \
           icewm:${pkgs.icewm}/bin/icewm-session \
           emacs:emacs                           \
           stumpwm:~/.stumpwm.d/init.ros           \
           exit &
           while :
           do
              sleep 1m
           done
      wait
    '';
  };
  services.cbatticon.enable = my.x11;
  services.emacs.enable = true;
  services.keynav.enable = my.x11;
  services.dunst.enable = my.x11;
  services.dunst.settings = {
    global = {
      frame_color = "#121212";
      separator_color = "#434343";
    };
    urgency_low = {
      background = "#585858";
      foreground = "#EAEAEA";
    };
    urgency_normal = {
      background = "#FFFFEA";
      foreground = "#121212";
    };
    urgency_critical = {
      background = "#AA222E";
      foreground = "#959DCB";
    };
    global.font = "Terminus";
    global.alignment = "right";
    global.word_warp = "true";
    global.line_height = 3;
    global.geometry = "384x5-30+20";
    urgency_low.timeout = 5;
    urgency_normal.timeout = 15;
    urgency_critical.timeout = 0;
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
  accounts.email.accounts =
    if (lib.pathExists ./mail.nix) then (import ./mail.nix) else {};
  programs.mbsync.enable = lib.pathExists ./mail.nix;
  programs.msmtp.enable = lib.pathExists ./mail.nix;
  services.xcape.enable = my.x11;
  services.gpg-agent = {
    grabKeyboardAndMouse = true;
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryFlavor = "gtk2";
  };
  programs.notmuch = {
    enable = lib.pathExists ./mail.nix;
    new = {
      tags = [ "new" ];
    };
    hooks = {
      postInsert = '''';
      preNew  = ''mbsync --all || true'';
      postNew = ''
        NEW_MAIL=$(notmuch count tag:new)
        if [ "$NEW_MAIL" -gt 0 ]
        then
           ${pkgs.libnotify}/bin/notify-send "Mail arrived: $(notmuch count tag:new)"
           notmuch tag +inbox +unread -new -- tag:new
        fi
      '';
    };
  };
  services.mbsync.enable = lib.pathExists ./mail.nix;
  programs.go.enable = true;
  programs.nix-index.enable = true;
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "${../wp/1.jpeg}";
      picture-options = "centered";
    };
    "org/gnome/desktop/sound" = { event-sounds = false; };
    "org/gnome/desktop/input-sources" = {
      xkb-options = config.home.keyboard.options;
      sources = builtins.map (x: "('xkb', '${x}')")
        (lib.strings.splitString "," config.home.keyboard.layout);
    };
  };
  programs.sbt = {
    enable = true;
    package = pkgs.sbt-with-scala-native;
    plugins = [ ];
  };
  programs.mpv = {
    enable = true;
    config = {
      "save-position-on-quit" = true;
      "osc" = "no";
    };
    scripts = with pkgs.mpvScripts; [ thumbnail ];
  };
  systemd.user.startServices = true;
  systemd.user.servicesStartTimeoutMs = 10000;
  programs.autorandr = {
    enable = true;
    hooks = {
      postswitch = {
        "icewm-restart" = "${pkgs.icewm}/bin/icesh restart";
        "dunst-restart" = "systemctl --user restart dunst.service";
        "background" = ''${pkgs.feh}/bin/feh --no-fehbg --bg-center ${../wp/1.jpeg}'';
        "fix-dpi" = ''
               case "$AUTORANDR_CURRENT_PROFILE" in
                 docked)
                   DPI=192
                   ;;
                 mobile)
                   DPI=96
                   ;;
                 *)
                   echo "Unknown profile: $AUTORANDR_CURRENT_PROFILE"
                   exit 1
               esac
               echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
         '';
      };
    };
  };
  systemd.user.services.notmuch = {
    Unit = {
      Requires = [ "davmail.service" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.notmuch}/bin/notmuch new";
      Environment = [ "PATH=${pkgs.isync}/bin:${pkgs.pass}/bin:$PATH" ];
    };
  };
  systemd.user.timers.notmuch = {
    Install = {
      WantedBy = [ "timers.target" ];
    };
    Timer = {
      OnBootSec = "10m"; # first run 10min after boot up
      OnCalendar = "*:0/5";
    };
  };
  systemd.user.services.davmail = {
    Unit = {
      Description = "Davmail";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.davmail}/bin/davmail";
      Environment = [ "PATH=${pkgs.coreutils}/bin:$PATH" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  systemd.user.services.volumeicon = {
    Unit = {
      Description = "Volumeicon";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.volumeicon}/bin/volumeicon";
      Environment = [ "PATH=${pkgs.coreutils}/bin:$PATH" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "daily";
  };
  services.mpdris2 = {
    notifications = true;
    enable = my.desktop;
  };
  xdg.userDirs.music = "~/Music";
  services.mpd = {
    enable = my.desktop;
    musicDirectory = ~/Music;
    extraConfig = ''
       audio_output {
          type "pipewire"
          name "My PipeWire Output"
       }
       follow_outside_symlinks "yes"
       follow_inside_symlinks "yes"
'';

  };
  programs.ncmpcpp.enable = my.desktop;
}
