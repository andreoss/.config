{
  config,
  lib,
  ...
}:
{
  config = {
    services.gammastep = {
      enable = config.xsession.enable;
      longitude = -55.0;
      latitude = -27.0;
      temperature = {
        day = 8000;
        night = 4500;
      };
      tray = true;
    };
    services.udiskie = {
      enable = config.xsession.enable;
      automount = false;
    };
    services.cbatticon.enable = config.xsession.enable;
    services.keynav.enable = config.xsession.enable;
    services.sxhkd = {
      enable = config.xsession.enable;
      keybindings = {
        "XF86MonBrightnessDown" = "xbacklight -dec 10";
        "XF86MonBrightnessUp" = "xbacklight -inc 10";
        "XF86Display" = ''
          if systemctl --user is-active gammastep.service;then systemctl --user stop gammastep.service ; else systemctl --user start gammastep.service; fi
                    inactive'';
      };
    };
  };
}
