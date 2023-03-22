{ config, pkgs, lib, ... }: {
  imports = [ ];

  options = {
    home.development.lisp = {
      enable = lib.mkEnableOption "Lisp development environment.";
      default = true;
    };
  };

  config = {
    home.packages = with pkgs; [ roswell sbcl babashka leiningen clojure ];
    home.activation.roswellInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ros init
    '';
  };
}
