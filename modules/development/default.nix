{ config, pkgs, ... }: {
  imports = [
    ./cxx.nix
    ./go.nix
    ./perl.nix
    ./java.nix
    ./scala.nix
    ./lisp.nix
    ./haskell.nix
    ./rust.nix
    ./ruby.nix
    ./python.nix
    ./vcs.nix
  ];

  config = {
    programs.jq.enable = true;
    home.packages = with pkgs; [
      ack
      ascii
      atool
      cloc
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
