{ config, ... }: {
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.trusted-users = [ "root" config.ao.primaryUser.name ];
    settings.auto-optimise-store = true;
    settings.build-cores = 4;
    settings.require-sigs = true;
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "00:00";
      options = "--delete-older-than 5d";
    };
  };
}
