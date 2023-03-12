{ config, pkgs, lib, stdenv, self, ... }:
let
  palette = import ../os/palette.nix;
  python3Plus = pkgs.python3.withPackages
    (ps: with ps; [ pep8 ipython pandas pip meson seaborn pyqt5 tkinter ]);
  python2Plus = pkgs.python27.withPackages (ps: with ps; [ pep8 pip ]);
  sbclPackages = (with pkgs; [ roswell sbcl ]);
  clojurePackages = with pkgs; [ babashka leiningen clojure ];
  my = {
    lang.ruby.packages = with pkgs; [ ruby gem ];
    lang.rust.packages = with pkgs; [ rust-analyzer rustup ];
  };
  lang = config.ao.primaryUser.languages;
  desk = config.ao.primaryUser.graphics;
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
  home.activation.roswellInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ "${
      builtins.toString config.ao.primaryUser.languages.lisp
    }" == "true" ] && ros init
  '';
  home.packages = with pkgs;
    [
      ack
      ascii
      atool
      cloc
      coreutils
      curl
      dig.dnsutils
      docker
      dockfmt
      entr
      file
      jwhois
      libressl
      lsof
      mtr
      nix
      nil
      nixfmt
      nix-tree
      nvi
      oathToolkit
      openvpn
      packer
      pavucontrol
      psmisc
      pulsemixer
      pv
      qrencode
      ripgrep
      rnix-lsp
      rsync
      screen
      shellcheck
      shfmt
      silver-searcher
      sysstat
      telescope
      unar
      unzip
      wget
      zip
      (hunspellWithDicts [
        hunspellDicts.ru_RU
        hunspellDicts.es_ES
        hunspellDicts.en_GB-large
      ])
      playerctl
      python3Plus
    ]
    ++ [ yamllint xmlformat yaml2json json2yaml yaml-merge jo libxslt dos2unix ]
    ++ (lib.optionals (!config.mini && config.ao.primaryUser.media) [
      imagemagickBig
      ffmpeg-full
      mpc_cli
    ]) ++ (lib.optionals (!config.mini && desk) [ signal-desktop ]) ++ [ ]
    ++ (lib.optionals (!config.mini && lang.cxx) [
      autoconf
      automake
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
      gnumake
      indent
      kubernetes
      lcov
      minikube
      minishift
      ninja
      openshift
      pkg-config
      strace
      tinycc
      valgrind
    ]) ++ (lib.optionals (!config.mini && config.ao.primaryUser.office) [
      djview
      pandoc
      libertine
      paperkey
      texlive.combined.scheme-full
      sdcv
      anki-bin
    ]) ++ (lib.optionals (!config.mini && config.ao.primaryUser.office) [
      #libreoffice
      abiword
      freerdp
    ]) ++ (lib.optionals (lang.lisp) sbclPackages)
    ++ (lib.optionals (lang.haskell) [
      ghc
      haskellPackages.stack
      haskell-language-server
    ]) ++ (lib.optionals (!config.mini && lang.ruby) my.lang.ruby.packages)
    ++ (lib.optionals (!config.mini && lang.rust) my.lang.rust.packages)
    ++ (lib.optionals (!config.mini && lang.clojure) clojurePackages);
  home.file = {
    ".npmrc".source = ./../npmrc;
    ".ratpoisonrc".source = ./../ratpoisonrc;
    ".indent.pro".source = ./../indent.pro;
    ".local/bin/dates".source = ./../scripts/dates;
    # ".local/bin/citrix".source = (pkgs.substituteAll {
    #   src = ./../scripts/citrix;
    #   citrix = pkgs.citrix_workspace_22_05_0;
    # });
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
  programs.mpv = {
    enable = config.ao.primaryUser.media;
    config = {
      save-position-on-quit = true;
      osc = "yes";
      osd-font-size = 24;
      osd-color = palette.white2;
    };
    scripts = with pkgs.mpvScripts; [ mpris ];
  };
  services.home-manager.autoUpgrade = {
    enable = false;
    frequency = "daily";
  };
  services.playerctld = {
    enable = !config.mini && config.ao.primaryUser.media;
  };
  services.mpdris2 = {
    notifications = true;
    enable = !config.mini && config.ao.primaryUser.media;
  };
  services.mpd = {
    enable = !config.mini && config.ao.primaryUser.media;
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
  programs.ncmpcpp.enable = !config.mini && config.ao.primaryUser.media;
  programs.zathura = {
    enable = desk;
    mappings = {
      "D" = "first-page-column 1:2";
      "<C-d>" = "first-page-column 1:1";
    };
    options = {
      selection-clipboard = "clipboard";
      sandbox = "strict";
      default-bg = palette.white2;
      default-fg = palette.black1;
    };
  };
  programs.yt-dlp = {
    enable = desk;
    settings = {
      convert-subs = "srt";
      downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
      downloader = "aria2c";
      embed-metadata = true;
      embed-subs = true;
      embed-thumbnail = true;
      mtime = true;
      sub-langs = "all";
    };
  };
  programs.home-manager.enable = true;
  programs.aria2 = {
    enable = !config.mini && config.ao.primaryUser.media;
    settings = { seed-ratio = 0.0; };
  };
}
