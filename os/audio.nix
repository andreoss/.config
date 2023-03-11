{ lib, config, ... }:
let
  cfg = config.ao;
  user = cfg.primaryUser.name;
in {
  hardware.bluetooth.enable = false;
  security.rtkit.enable = !config.ao.pipewireReplacesPulseaudio;
  hardware.pulseaudio = {
    enable = !config.ao.pipewireReplacesPulseaudio;
    systemWide = true;
    tcp = {
      enable = true;
      anonymousClients = {
        allowedIpRanges = [ "127.0.0.1" "192.168.99.0/28" ];
      };
    };
  };
  services.pipewire.enable = lib.mkForce config.ao.pipewireReplacesPulseaudio;
  services.pipewire.alsa.enable = config.ao.pipewireReplacesPulseaudio;
  services.pipewire.pulse.enable = config.ao.pipewireReplacesPulseaudio;
  users.groups.audio.members = [ user ];
  users.groups.pulse.members = [ user ];
  users.groups.pulse-access.members = [ user ];
}
