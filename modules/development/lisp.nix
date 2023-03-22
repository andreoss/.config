{ config, pkgs, lib, ... }: {
  imports = [ ];

  options = {
    home.development.lisp = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = {
    home.packages = with pkgs; [ roswell sbcl babashka leiningen clojure ];
    home.activation.roswellInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ros init
    '';
  };
}
