{ lib, pkgs, config, self, ... }: {
  users.mutableUsers = false;
  users.motd = "";
  users.defaultUserShell = pkgs.bash;
  users.users.root.initialHashedPassword =
    lib.mkForce "$6$vOuTgR3jF.ZJjRje$iWA5cET.4Ak/If9ocTp3ttRw1QjTZNmshEkLXv8r.tCI6MNYddWuOK9kqseLNct3C/MncuRnkPRlNry1KppHM/";
  users.users."${self.config.primaryUser.name}" = {
    uid = 1337;
    initialHashedPassword =
      "$6$FpbouABGBk53rccL$9.YA5q3qJOo0SHjJlZ.yjPjg.xczCkIHqJtcaeGbkt9N5//M60s8VzoTWhNy1FIPOQdT9aKGSgCv0GShLzDxo/";
    isNormalUser = true;
    createHome = true;
    home = self.config.primaryUser.home;
  };
  users.extraGroups.wheel.members = [ self.config.primaryUser.name ];
  services.logind.killUserProcesses = true;
  services.logind.lidSwitch = "suspend";
  services.logind.extraConfig = "";
  environment = {
    noXlibs = false;
    defaultPackages = with pkgs; [ ];
    systemPackages = with pkgs; [
      acpi
      home-manager
      lm_sensors
      man-pages
      man-pages-posix
      nvi
      psmisc
      stdmanpages
      wpa_supplicant_gui
    ];
    shellAliases = { };
    homeBinInPath = true;
    variables.TOR_SOCKS_PORT = "9150";
    etc = {
      "inputrc".source = ./../inputrc;
      "issue".source = lib.mkOverride 0 (pkgs.writeText "issue" "");
    };
    loginShellInit = ''
      [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
    '';
  };
}
