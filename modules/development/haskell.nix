{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.home.development.haskell;
in
{
  imports = [ ];
  options = {
    home.development.haskell = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ghc
      smlnj
      haskellPackages.stack
      haskellPackages.cabal-install
      haskell-language-server
    ];
  };
}
