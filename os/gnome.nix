{ lib, config, pkgs, ... }:
{
  services.gnome.gnome-initial-setup.enable = false;
  services.gnome.gnome-user-share.enable = false;
  services.gnome.gnome-browser-connector.enable = false;
  services.gnome.tracker-miners.enable = false;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs.gnome; [
    gedit
    gnome-music
    gnome-terminal
    gnome-contacts
    gnome-calendar
    gnome-screenshot
    gnome-characters
    gnome-calculator
    gnome-maps
    gnome-weather
    gnome-clocks
    gnome-logs
    gnome-control-center
    gnome-system-monitor
    gnome-font-viewer
    gnome-disk-utility
  ];
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
        [org.gnome.desktop.background]
        picture-uri="${../wp/1.jpeg}"
        picture-options='centered'
        primary-color='#3b77bc'
        secondary-color='#023c88'
        [org.gnome.desktop.sound]
        event-sounds=false
        [org.gnome.desktop.privacy]
        disable-microphone=true
        hide-identity=true
        recent-files-max-age=0
        remove-old-temp-files=true
        remember-app-usage=false
        disable-camera=true
        remember-recent-files=false
        report-technical-problems=false
        remove-old-trash-files=true
        show-full-name-in-top-bar=false
        send-software-usage-stats=false
        [org.gnome.desktop.default-applications.terminal]
        exec-arg="-x"
        exec="urxvt"
        [org.gnome.mutter]
        dynamic-workspaces=true
        center-new-windows=true
        [org.gnome.nautilus.preferences]
        automatic-decompression=false
        sort-directories-first=true
        [org.gtk.settings.file-chooser]
        sort-directories-first=true
        location-mode='path-bar'
  '';
}
