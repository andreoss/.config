{ config, ... }: {
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.trusted-users = [ "root" config.ao.primaryUser.name ];
    settings.substituters =
      [ "https://kernel-overlay.cachix.org" "https://emacs-d.cachix.org" ];
    settings.trusted-public-keys = [
      "emacs-d.cachix.org-1:ZVKHC1i/NOKVCI1M5A99Oupph+rEAJcYEWpdd3UDz5g="
      "kernel-overlay.cachix.org-1:rUvSa2sHn0a7RmwJDqZvijlzZHKeGvmTQfOUr2kaxr4="
    ];
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
