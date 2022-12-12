{ config , ... }: {
  nixpkgs.config = {
    pulseaudio = true;
    mediaSupport = true;
  };
  hardware.bluetooth.enable = false;
  security.rtkit.enable = !config.ao.pipewireReplacesPulseaudio;
  hardware.pulseaudio.enable = !config.ao.pipewireReplacesPulseaudio;
  services.pipewire.enable = config.ao.pipewireReplacesPulseaudio;
  services.pipewire.alsa.enable = config.ao.pipewireReplacesPulseaudio;
  services.pipewire.pulse.enable = config.ao.pipewireReplacesPulseaudio;
  users.groups.pulse-access = { };
  users.extraGroups.audio.members = [ config.ao.primaryUser.name ];
}
