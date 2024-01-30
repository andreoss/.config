{ config, pkgs, lib, ... }:
let cfg = config.home.development.lisp;
in {
  imports = [ ];

  options = {
    home.development.lisp = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [ roswell sbcl babashka leiningen clojure ];
      activation.roswellInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        PATH=$PATH:${pkgs.roswell}/bin
        if type ros
        then
          ros init
        fi
      '';
    };
  };
}
