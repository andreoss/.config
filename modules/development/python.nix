{
  config,
  pkgs,
  lib,
  stdenv,
  self,
  ...
}:
let
  cfg = config.home.development.python;
  python3Plus = pkgs.python3.withPackages (
    ps: with ps; [
      pep8
      ipython
      pandas
      pip
      meson
      tkinter
    ]
  );
in
{
  options = {
    home.development.python = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable [
      python3Plus
      pkgs.virtualenv
    ];
  };
}
