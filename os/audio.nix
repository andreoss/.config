{ lib, config, ... }:
let user = config.primaryUser.name;
in {
  hardware.bluetooth.enable = false;
  security.rtkit.enable = !config.preferPipewire;
  hardware.pulseaudio = {
    enable = !config.preferPipewire;
    systemWide = true;
  };
  services.pipewire.enable = lib.mkForce config.preferPipewire;
  services.pipewire.alsa.enable = config.preferPipewire;
  services.pipewire.pulse.enable = config.preferPipewire;
  users.groups.audio.members = [ user ];
  users.groups.pulse.members = [ user ];
  users.groups.pulse-access.members = [ user ];
  programs.noisetorch.enable = true;
}
