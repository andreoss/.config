{ self, ... }:
{
  nixpkgs.config = {
    pulseaudio = true;
    mediaSupport = true;
  };
  hardware.bluetooth.enable = false;
  security.rtkit.enable = !self.config.pipewireReplacesPulseaudio;
  hardware.pulseaudio.enable = !self.config.pipewireReplacesPulseaudio;
  services.pipewire.enable = self.config.pipewireReplacesPulseaudio;
  services.pipewire.alsa.enable = self.config.pipewireReplacesPulseaudio;
  services.pipewire.pulse.enable = self.config.pipewireReplacesPulseaudio;
  users.groups.pulse-access = { };
  users.extraGroups.audio.members = [
    self.config.primaryUser.name
 ];
}
