{ config, pkgs, ... }: {
  config = {
    xdg.mimeApps = { enable = true; };
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
    home.enableNixpkgsReleaseCheck = true;
    home.sessionPath = [ "$HOME/.local/bin" "$HOME/.config/scripts" ];
    home.keyboard = {
      layout = "us,ru";
      options = [ "ctrl:nocaps,grp:shifts_toggle" "compose:ralt" ];
    };
    home.sessionVariables = {
      XKB_DEFAULT_LAYOUT = config.home.keyboard.layout;
      XKB_DEFAULT_OPTIONS =
        builtins.concatStringsSep "," config.home.keyboard.options;
    };
    programs.ssh = { enable = true; };
    programs.keychain = {
      enable = true;
      enableBashIntegration = true;
    };
    programs.gpg.enable = true;
    services.gpg-agent = {
      grabKeyboardAndMouse = true;
      enable = true;
      defaultCacheTtl = 7200;
      enableSshSupport = true;
      pinentryFlavor = "gtk2";
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
    home.sessionVariables = { WLR_NO_HARDWARE_CURSORS = 1; };
    systemd.user.startServices = true;
    systemd.user.servicesStartTimeoutMs = 10000;
  };
}
