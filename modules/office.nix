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
        defaultApplications = {
          "application/pdf" = [ "sioyek.desktop" ];
          "inode/directory" = [ "pcmanfm.desktop" ];
          "text/plain" = [ "emacsclient.desktop" ];
          "image/bmp" = [ "feh.desktop" ];
          "image/gif" = [ "feh.desktop" ];
          "image/jpeg" = [ "feh.desktop" ];
          "image/jpg" = [ "feh.desktop" ];
          "image/pjpeg" = [ "feh.desktop" ];
          "image/png" = [ "feh.desktop" ];
          "image/tiff" = [ "feh.desktop" ];
          "image/webp" = [ "feh.desktop" ];
          "image/x-bmp" = [ "feh.desktop" ];
          "image/x-pcx" = [ "feh.desktop" ];
          "image/x-png" = [ "feh.desktop" ];
          "image/x-portable-anymap" = [ "feh.desktop" ];
          "image/x-portable-bitmap" = [ "feh.desktop" ];
          "image/x-portable-graymap" = [ "feh.desktop" ];
          "image/x-portable-pixmap" = [ "feh.desktop" ];
          "image/x-tga" = [ "feh.desktop" ];
          "image/x-xbitmap" = [ "feh.desktop" ];
          "image/heic" = [ "feg.desktop" ];
        };
      };
    };
    home = {
      packages = with pkgs; [
        abiword
        ditaa
        djview
        dmtx-utils
        drawio
        goat
        libertine
        libreoffice
        mermaid-filter
        pandoc
        pandoc-drawio-filter
        pandoc-imagine
        pandoc-katex
        pandoc-plantuml-filter
        plantuml
        poppler_utils
        sdcv
        texlive.combined.scheme-full
        xlsx2csv
        xlsxgrep
        zbar
      ];
    };
    programs = {
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
          default-bg = palette.white3;
          default-fg = palette.black2;
        };
      };
    };
  };
}
