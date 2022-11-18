{ config, pkgs, lib, stdenv, self, ... }:
let
  python3Plus = pkgs.python3.withPackages
    (ps: with ps; [ pep8 ipython pandas pip meson seaborn pyqt5 tkinter ]);
  python2Plus = pkgs.python27.withPackages (ps: with ps; [ pep8 pip ]);
  sbclPackages = (with pkgs; [ roswell sbcl clisp ]);
  jdkRelatedPackages = with pkgs; [
    android-tools
    heimdall
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
    terminus_font
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
    lang.haskell.enable = true;
    lang.office.enable = true;
    lang.perl.enable = true;
    lang.perl.packages = pkgs.perl536Packages;
    lang.ruby.enable = false;
    lang.ruby.packages = with pkgs; [ ruby gem ];
    lang.rust.enable = true;
    lang.rust.packages = with pkgs; [ rust-analyzer rustup ];
    lang.scala.enable = true;
    lang.tex.enable = true;
  };
in {
  nixpkgs.overlays = [
    (self: super: {
      heimdall = super.heimdall.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "deriamis";
          repo = "Heimdall";
          rev = "master";
          sha256 = "sha256-b94W+uwgvPK5TZbMgijFin4kYH0llFajcbtoQdZpnYs=";
        };
      });
    })
  ];
  nixpkgs.config = {
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball {
        url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
      }) { inherit pkgs; };
    };
  };
  programs.matplotlib.enable = true;
  programs.ssh = { enable = true; };
  home.enableNixpkgsReleaseCheck = true;
  home.sessionPath = [ "$HOME/.local/bin" "$HOME/.config/scripts" ];
  home.activation.roswellInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ "${builtins.toString my.lang.lisp.enable}}" == "true" ] && ros init
  '';
  programs.keychain = {
    enable = true;
    enableXsessionIntegration = true;
    enableBashIntegration = true;
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
    _JAVA_AWT_WM_NONREPARENTING = "1";
    _JAVA_OPTIONS =
      "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Djdk.gtk.version=3";
    WLR_NO_HARDWARE_CURSORS = 1;
    MAVEN_OPTS =
      "-Djava.awt.headless=true -Dorg.slf4j.simpleLogger.showDateTime=true -Dorg.slf4j.simpleLogger.dateTimeFormat=HH:mm:ss,SSS";
    XDG_SESSION_PATH = "";
    XDG_SESSION_DESKTOP = "";
    XDG_SESSION_TYPE = "";
    XDG_SESSION_CLASS = "";
    XDG_SESSION_ID = "";
    GDMSESSION = "";
    DESKTOP_SESSION = "";
    XDG_CURRENT_SESSION = "";
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
      telescope
      packer
      docker
      dockfmt
      entr
      file
      imagemagickBig
      jwhois
      libressl
      lsof
      minikube
      kubernetes
      minishift
      mtr
      nvi
      nix
      nixfmt
      nix-tree
      oathToolkit
      #openshift
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
      anki-bin
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
    ] ++ fontPackages ++ (lib.optionals (my.desktop) [
      wmname
      xclip
      xorg.xkill
      xorg.xdpyinfo
      rox-filer
      xdotool
    ])
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
    ]) ++ (lib.optionals (my.desktop) [ signal-desktop ]) ++ [
      fossil
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
    ]) ++ (lib.optionals (my.lang.tex.enable) [
      djview
      pandoc
      libertine
      texlive.combined.scheme-full
    ]) ++ (lib.optionals (my.lang.office.enable) [
      #libreoffice
      abiword
      freerdp
      davmail
    ]) ++ (lib.optionals (my.lang.lisp.enable) sbclPackages)
    ++ (lib.optionals (my.lang.haskell.enable) [
      ghc
      haskellPackages.stack
      haskell-language-server
    ]) ++ (lib.optionals (my.lang.ruby.enable) my.lang.ruby.packages)
    ++ (lib.optionals (my.lang.rust.enable) my.lang.rust.packages)
    ++ (lib.optionals (my.lang.java.enable) jdkRelatedPackages)
    ++ (lib.optionals (my.lang.go.enable) [ gotools gocode ])
    ++ (lib.optionals (my.lang.clojure.enable) clojurePackages)
    ++ (lib.optionals (my.lang.scala.enable) scalaPackages);
  home.file = {
    ".npmrc".source = ./../npmrc;
    ".ratpoisonrc".source = ./../ratpoisonrc;
    ".indent.pro".source = ./../indent.pro;
    ".local/bin/citrix".source = ./../scripts/citrix;
  };
  home.file.".local/bin/nano" = {
    executable = true;
    text = ''
      #!/bin/sh
      exit 1
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
  accounts.email.accounts = if (lib.pathExists ../secrets/mail.nix) then
    (import ../secrets/mail.nix)
  else
    { };
  programs.mbsync.enable = lib.pathExists ../secrets/mail.nix;
  programs.msmtp.enable = lib.pathExists ../secrets/mail.nix;
  services.gpg-agent = {
    grabKeyboardAndMouse = true;
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryFlavor = "gtk2";
  };
  programs.notmuch = {
    enable = lib.pathExists ../secrets/mail.nix;
    new = { tags = [ "new" ]; };
    hooks = {
      postInsert = "";
      preNew = "mbsync --all || true";
      postNew = ''
        NEW_MAIL=$(notmuch count tag:new)
        if [ "$NEW_MAIL" -gt 0 ]
        then
           ${pkgs.libnotify}/bin/notify-send "✉ + $(notmuch count tag:new) / $(notmuch count tag:unread)"
           notmuch tag +inbox +unread -new -- tag:new
        fi
      '';
    };
  };
  services.mbsync.enable = lib.pathExists ../secrets/mail.nix;
  programs.go.enable = true;
  programs.nix-index.enable = true;
  programs.mpv = {
    enable = true;
    config = {
      "save-position-on-quit" = true;
      "osc" = "no";
    };
    scripts = with pkgs.mpvScripts; [ ];
  };
  systemd.user.services.notmuch = {
    Unit = { Requires = [ "davmail.service" ]; };
    Install = { WantedBy = [ "default.target" ]; };
    Service = {
      ExecStart = "${pkgs.notmuch}/bin/notmuch new";
      Environment = [ "PATH=${pkgs.isync}/bin:${pkgs.pass}/bin:$PATH" ];
    };
  };
  systemd.user.timers.notmuch = {
    Install = { WantedBy = [ "timers.target" ]; };
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
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "daily";
  };
  services.mpdris2 = {
    notifications = true;
    enable = my.desktop;
  };
  services.mpd = {
    enable = my.desktop;
    musicDirectory = "${config.home.homeDirectory}/Music";
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
  programs.zathura.enable = my.desktop;
  programs.yt-dlp.enable = my.desktop;
  programs.home-manager.enable = true;
  systemd.user.startServices = true;
  systemd.user.servicesStartTimeoutMs = 10000;
}
