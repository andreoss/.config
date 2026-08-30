{
  config,
  pkgs,
  ...
}:
let
  cfg = config;
  host = "192.168.99.1";
  user = cfg.primaryUser.name;
in
{
  containers.gateway = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = host;
    localAddress = "192.168.99.3";
    config =
      { config, pkgs, ... }:
      {
        system.stateVersion = cfg.stateVersion;
        services.openssh.enable = true;
        services.xserver.enable = true;
        services.openssh.settings.X11Forwarding = false;
        systemd.tmpfiles.rules = [
          "d /nix/var/nix/profiles/per-user/${user} - ${user} - - -"
          "d /nix/var/nix/gcroots/per-user/${user} - ${user} - - -"
        ];
        users.users."${user}" = {
          uid = cfg.primaryUser.uid;
          isNormalUser = true;
          createHome = true;
          openssh.authorizedKeys.keys = cfg.primaryUser.authorizedKeys;
        };
        environment = {
          defaultPackages = with pkgs; [ ];
          systemPackages = with pkgs; [
            xpra
            cwm
            tor-browser
            pulseaudio
          ];
        };
      };
  };
}
