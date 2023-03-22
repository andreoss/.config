{ config, pkgs, lib, stdenv, self, ... }:
let
  palette = import ../os/palette.nix;
  python3Plus = pkgs.python3.withPackages
    (ps: with ps; [ pep8 ipython pandas pip meson seaborn pyqt5 tkinter ]);
  python2Plus = pkgs.python27.withPackages (ps: with ps; [ pep8 pip ]);
  my = {
    lang.ruby.packages = with pkgs; [ ruby gem ];
    lang.rust.packages = with pkgs; [ rust-analyzer rustup ];
  };
  lang = config.ao.primaryUser.languages;
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
  programs.matplotlib.enable = true;
  home.packages = with pkgs;
    [
      ack
      ascii
      atool
      coreutils-full
      docker
      dockfmt
      file
      libressl
      lsof
      nix
      nil
      nixfmt
      nix-tree
      nvi
      oathToolkit
      openvpn
      packer
      pavucontrol
      pulsemixer
      psmisc
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
      unar
      unzip
      zip
      (hunspellWithDicts [
        hunspellDicts.ru_RU
        hunspellDicts.es_ES
        hunspellDicts.en_GB-large
      ])
      python3Plus
    ]
    ++ [ yamllint xmlformat yaml2json json2yaml yaml-merge jo libxslt dos2unix ]
    ++ (lib.optionals (!config.mini && lang.cxx) [
      kubernetes
      lcov
      minikube
      minishift
      ctop
      ninja
      openshift
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
    ]) ++ (lib.optionals (!config.mini && lang.ruby) my.lang.ruby.packages)
    ++ (lib.optionals (!config.mini && lang.rust) my.lang.rust.packages);
  home.file = {
    ".npmrc".source = ./../npmrc;
    ".ratpoisonrc".source = ./../ratpoisonrc;
    ".local/bin/dates".source = ./../scripts/dates;
  };
  home.file.".local/bin/nano" = {
    executable = true;
    text = ''
      #!/bin/sh
      exit 1
    '';
  };
  services.home-manager.autoUpgrade = {
    enable = false;
    frequency = "daily";
  };
  programs.zathura = {
    enable = config.xsession.enable;
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
  programs.jq.enable = true;
  programs.home-manager.enable = true;
}
