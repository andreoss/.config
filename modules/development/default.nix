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
      docker-credential-gcr
      dockfmt
      dos2unix
      (google-cloud-sdk.withExtraComponents ([
        google-cloud-sdk.components.cloud-build-local
        google-cloud-sdk.components.gke-gcloud-auth-plugin
      ]))
      jo
      json2yaml
      k9s
      kail
      kubernetes
      lcov
      libxslt
      lsof
      mariadb-client
      minikube
      nil
      ninja
      nix
      nixfmt
      nix-tree
      nodePackages_latest.bash-language-server
      openshift
      pgtop
      postgresql
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
      sshfs
      sysstat
      trivy
      turbovnc
      unar
      unzip
      xmlformat
      yaml2json
      yamllint
      yaml-merge
      zip
    ];
  };
}
