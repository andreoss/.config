{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.home.development.js;
in
{
  options = with lib; {
    home.development.js = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = {
    home = lib.mkIf cfg.enable {
      packages =
        (with pkgs; [
          nodejs_18
          quick-lint-js
          rslint
          mujs
        ])
        ++ (with pkgs.elmPackages; [
          elm
          create-elm-app
          elm-analyse
          elm-coverage
        ])
        ++ (with pkgs.nodePackages; [
          eslint
          typescript
          typescript-language-server
          yarn
          pnpm
        ]);
    };
  };
}
