{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
let
  palette = import ./palette.nix;
in
{
  console = {
    packages = [ pkgs.uw-ttyp0 ];
    font = "t0-18b-uni";
    colors = builtins.map (x: builtins.replaceStrings [ "#" ] [ "" ] x) (
      with palette;
      [
        blue7
        red1
        green1
        yellow1
        blue1
        red3
        cyan1
        white3
        black2
        orange1
        gray5
        gray2
        gray3
        magenta
        red3
        white1
      ]
    );
  };
}
