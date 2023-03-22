{ config, pkgs, lib, inputs, ... }: {
  imports =
    [ ./cxx.nix ./perl.nix ./java.nix ./scala.nix ./lisp.nix ./haskell.nix ];

  config = {
    programs.jq.enable = true;
    home.packages = with pkgs; [
      ack
      ascii
      atool
      docker
      dockfmt
      lsof
      nil
      nix
      nixfmt
      nix-tree
      packer
      psmisc
      pv
      qrencode
      ripgrep
      rnix-lsp
      rsync
      shellcheck
      shfmt
      silver-searcher
      sysstat
      unar
      unzip
      zip

      kubernetes
      lcov
      minikube
      minishift
      ctop
      ninja
      openshift

      yamllint
      xmlformat
      yaml2json
      json2yaml
      yaml-merge
      jo
      libxslt
      dos2unix

    ];
  };
}
