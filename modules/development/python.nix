{ config, pkgs, lib, stdenv, self, ... }:
let
  cfg = config.home.development.python;
  python3Plus = pkgs.python3.withPackages
    (ps: with ps; [ pep8 ipython pandas pip meson seaborn pyqt5 tkinter ]);
  python2Plus = pkgs.python27.withPackages (ps: with ps; [ pep8 pip ]);
in {
  options = {
    home.development.python = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = {
    programs.matplotlib.enable = cfg.enable;
    home.packages = lib.optionals cfg.enable [ python3Plus python2Plus ];
  };
}
