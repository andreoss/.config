{ config, pkgs, ... }: {
  imports = [
    ./cxx.nix
    ./go.nix
    ./haskell.nix
    ./java.nix
    ./js.nix
    ./lisp.nix
    ./perl.nix
    ./python.nix
    ./ruby.nix
    ./rust.nix
    ./scala.nix
    ./vcs.nix
  ];

  config = {
    programs.jq.enable = true;
    home.packages = with pkgs; [
      act
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
      mariadb-client
    ];
  };
}
