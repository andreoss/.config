{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.home.web;
in
{
  imports = [ ];
  options = {
    home.web = {
      enable = lib.mkEnableOption "Web programs.";
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        libressl
        wget
        curl
        telescope
        dig.dnsutils
        jwhois
        mtr
        monero-gui
        ungoogled-chromium
        tdesktop
        signal-desktop
        transmission-gtk
      ];
    };
    programs = {
      browserpass = {
        enable = config.programs.password-store.enable;
        browsers = [
          "brave"
          "chromium"
          "librewolf"
        ];
      };
      chromium.enable = true;
      chromium.package = pkgs.brave;
    };
  };
}
