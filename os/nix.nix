{ config, pkgs, ... }: {
  nix =
    let cores = pkgs.runCommand "cores.nix" { } ''nproc --ignore=2 > "$out"'';
    in {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      settings = {
        cores = import "${cores}";
        experimental-features = [ "nix-command" "flakes" ];
        substituters =
          [ "https://kernel-overlay.cachix.org" "https://emacs-d.cachix.org" ];
        trusted-public-keys = [
          "emacs-d.cachix.org-1:ZVKHC1i/NOKVCI1M5A99Oupph+rEAJcYEWpdd3UDz5g="
          "kernel-overlay.cachix.org-1:rUvSa2sHn0a7RmwJDqZvijlzZHKeGvmTQfOUr2kaxr4="
        ];
        auto-optimise-store = true;
        require-sigs = true;
      };
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "00:00";
        options = "--delete-older-than 5d";
      };
    };
}
