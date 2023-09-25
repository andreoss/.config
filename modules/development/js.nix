{ config, pkgs, lib, ... }:
let cfg = config.home.development.js;
in {
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
      packages = (with pkgs; [ nodejs_18 quick-lint-js rslint v8 ])
        ++ (with pkgs.nodePackages; [
          eslint
          react-native-cli
          react-static
          react-tools
          typescript
          typescript-language-server
          yarn
          pnpm
        ]);
    };

  };
}
