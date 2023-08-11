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
  };
  services.pipewire.enable = lib.mkForce config.ao.pipewireReplacesPulseaudio;
  services.pipewire.alsa.enable = config.ao.pipewireReplacesPulseaudio;
  services.pipewire.pulse.enable = config.ao.pipewireReplacesPulseaudio;
  users.groups.audio.members = [ user ];
  users.groups.pulse.members = [ user ];
  users.groups.pulse-access.members = [ user ];
  programs.noisetorch.enable = true;
}
