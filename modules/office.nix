{ config, pkgs, lib, inputs, ... }:
let
  palette = import ../os/palette.nix;
  cfg = config.home.office;
in {
  imports = [ ];
  options = {
    home.office = with lib; {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        abiword
        djview
        libertine
        pandoc
        sdcv
        texlive.combined.scheme-full
      ];
    };
    programs = {
      zathura = {
        enable = config.xsession.enable;
        mappings = {
          "D" = "first-page-column 1:2";
          "<C-d>" = "first-page-column 1:1";
        };
        options = {
          selection-clipboard = "clipboard";
          sandbox = "strict";
          default-bg = palette.white2;
          default-fg = palette.black1;
        };
      };
    };
  };
}
