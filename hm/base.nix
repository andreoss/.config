{ config, pkgs, ... }:
{
  config = {
    xdg.mimeApps = {
      enable = true;
    };
    xdg.configFile."mimeapps.list".force = true;
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
    home.enableNixpkgsReleaseCheck = true;
    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.config/scripts"
    ];
    home.keyboard = {
      layout = "us,ru";
      options = [
        "ctrl:nocaps,grp:shifts_toggle"
        "compose:ralt"
      ];
    };
    home.sessionVariables = {
      XKB_DEFAULT_LAYOUT = config.home.keyboard.layout;
      XKB_DEFAULT_OPTIONS = builtins.concatStringsSep "," config.home.keyboard.options;
    };
    home.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = 1;
    };
    programs.ssh = {
      enable = true;
    };
    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [
        exts.pass-otp
        exts.pass-import
        exts.pass-update
        exts.pass-genphrase
      ]);
    };
    programs.gpg = {
      enable = true;
    };
    services.gpg-agent = {
      grabKeyboardAndMouse = true;
      enable = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      pinentryPackage = pkgs.pinentry-all;
      maxCacheTtl = 24 * 60 * 60;
      extraConfig = ''
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
    };
    systemd.user.startServices = true;
    systemd.user.servicesStartTimeoutMs = 10000;
  };
}
