{ config, pkgs, lib, stdenv, self, ... }:
let
  palette = import ../os/palette.nix;
  python3Plus = pkgs.python3.withPackages
    (ps: with ps; [ pep8 ipython pandas pip meson seaborn pyqt5 tkinter ]);
  python2Plus = pkgs.python27.withPackages (ps: with ps; [ pep8 pip ]);
  sbclPackages = (with pkgs; [ roswell sbcl clisp ]);
  clojurePackages = with pkgs; [ babashka leiningen clojure ];
  my = {
    desktop = true;
    lang.clojure.enable = true;
    lang.cpp.enable = true;
    lang.lisp.enable = true;
    lang.haskell.enable = true;
    lang.office.enable = true;
    lang.ruby.enable = false;
    lang.ruby.packages = with pkgs; [ ruby gem ];
    lang.rust.enable = true;
    lang.rust.packages = with pkgs; [ rust-analyzer rustup ];
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
  programs.keychain = {
    enable = true;
    enableXsessionIntegration = true;
    enableBashIntegration = true;
  };
  programs.gpg.enable = true;
  services.gpg-agent = {
    grabKeyboardAndMouse = true;
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryFlavor = "gtk2";
  };
  home.enableNixpkgsReleaseCheck = true;
  home.sessionPath = [ "$HOME/.local/bin" "$HOME/.config/scripts" ];
  home.activation.roswellInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ "${builtins.toString my.lang.lisp.enable}}" == "true" ] && ros init
  '';
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
    WLR_NO_HARDWARE_CURSORS = 1;
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
    ]
    ++ [ yamllint xmlformat yaml2json json2yaml yaml-merge jo libxslt dos2unix ]
    ++ (lib.optionals (my.desktop) [
      ffmpeg-full
      mpc_cli
    ]) ++ (lib.optionals (my.desktop) [ signal-desktop ]) ++ [
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
    ]) ++ (lib.optionals (my.lang.lisp.enable) sbclPackages)
    ++ (lib.optionals (my.lang.haskell.enable) [
      ghc
      haskellPackages.stack
      haskell-language-server
    ]) ++ (lib.optionals (my.lang.ruby.enable) my.lang.ruby.packages)
    ++ (lib.optionals (my.lang.rust.enable) my.lang.rust.packages)
    ++ (lib.optionals (my.lang.clojure.enable) clojurePackages)
  ;
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
  programs.command-not-found.enable = true;
  programs.mpv = {
    enable = true;
    config = {
      "save-position-on-quit" = true;
      "osc" = "no";
    };
    scripts = with pkgs.mpvScripts; [ ];
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
  programs.zathura = {
    enable = my.desktop;
    options = {
      default-bg = palette.white2;
      default-fg = palette.black1;
    };
  };
  programs.yt-dlp.enable = my.desktop;
  programs.home-manager.enable = true;
  programs.aria2 = {
    enable = my.desktop;
    settings = {
      seed-ratio = 0.0;
    };
  };
  systemd.user.startServices = true;
  systemd.user.servicesStartTimeoutMs = 10000;
}
