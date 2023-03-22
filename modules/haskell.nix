{ config, pkgs, lib, ... }: {
  imports = [ ];

  options = {
    home.development.haskell = {
      enable = lib.mkEnableOption "Haskell development environment.";
      default = true;
    };
  };

  config = {
    home.packages = with pkgs; [
      ghc
      haskellPackages.stack
      haskell-language-server

    ];
  };
}
