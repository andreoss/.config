{ config, pkgs, lib, ... }:
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
    xdg = {
      desktopEntries = {
        zathura = {
          name = "Zathura";
          exec = "zathura %U";
          terminal = false;
          categories = [ "Office" ];
          mimeType = [ "application/pdf" ];
        };
      };
      mimeApps = {
        defaultApplications = { "application/pdf" = [ "zathura.desktop" ]; };
      };
    };
    home = {
      packages = with pkgs; [
        abiword
        djview
        libertine
        pandoc
        sdcv
        xlsx2csv
        xlsxgrep
        zbar
        dmtx-utils
        calibre
      ];
    };
    programs = {
      texlive = {
        enable = true;
        packageSet = pkgs.texlive;
      };
      sioyek.enable = config.xsession.enable;
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
