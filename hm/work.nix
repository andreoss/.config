{
  config,
  pkgs,
  lib,
  stdenv,
  inputs,
  ...
}:
{
  config = {
    xdg.desktopEntries = {
      citrix = {
        name = "Citrix";
        genericName = "Citrix Client";
        exec = "wfica %U";
        terminal = false;
        categories = [ "Network" ];
        mimeType = [ "application/x-ica" ];
      };
    };
    xdg.mimeApps = {
      defaultApplications = {
        "application/x-ica" = [ "citrix.desktop" ];
      };
    };
    programs.browserpass = {
      enable = true;
      browsers = [ "chromium" ];
    };
    programs.chromium = {
      enable = true;
      extensions = [
        {
          # "https://chrome.google.com/webstore/detail/browserpass-ce/naepdomgkenhinolocfifgehidddafch";
          id = "naepdomgkenhinolocfifgehidddafch";
        }
        {
          # https://github.com/james-fray/tab-reloader
          id = "dejobinhdiimklegodgbmbifijpppopn";
        }
      ];
    };
    home.packages = with pkgs; [
      inputs.wfica.packages.x86_64-linux.wfica
      xorg.xhost
      ratpoison
    ];
    home.file = {
      ".local/bin/dates".source = ./../scripts/dates;
    };
  };
}
