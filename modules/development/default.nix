{ pkgs, ... }: {
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
      ack
      act
      ascii
      atool
      cloc
      ctop
      docker
      dockfmt
      dos2unix
      jo
      json2yaml
      kubernetes
      lcov
      libxslt
      lsof
      mariadb-client
      minikube
      minishift
      nil
      ninja
      nix
      nixfmt
      nix-tree
      nodePackages_latest.bash-language-server
      openshift
      packer
      postgresql
      pgtop
      psmisc
      pv
      qrencode
      ripgrep
      rnix-lsp
      rsync
      shellcheck
      shfmt
      silver-searcher
      sleek
      sysstat
      unar
      unzip
      xmlformat
      yaml2json
      yamllint
      yaml-merge
      zip
      docker-credential-gcr
      (google-cloud-sdk.withExtraComponents ([
        google-cloud-sdk.components.cloud-build-local
        google-cloud-sdk.components.gke-gcloud-auth-plugin
      ]))
      trivy
      mysql-workbench
      localstack
    ];
  };
}
