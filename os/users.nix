{ lib, pkgs, config, self, ... }: {
  users.mutableUsers = false;
  users.motd = "";
  users.defaultUserShell = pkgs.bash;
  users.users.root.initialHashedPassword = lib.mkForce
    "$6$vOuTgR3jF.ZJjRje$iWA5cET.4Ak/If9ocTp3ttRw1QjTZNmshEkLXv8r.tCI6MNYddWuOK9kqseLNct3C/MncuRnkPRlNry1KppHM/";
  users.users."${config.ao.primaryUser.name}" = {
    uid = config.ao.primaryUser.uid;
    initialHashedPassword = config.ao.primaryUser.passwd;
    isNormalUser = true;
    createHome = true;
    home = config.ao.primaryUser.home;
  };
  users.extraGroups.wheel.members = [ config.ao.primaryUser.name ];
  services.logind.killUserProcesses = true;
  services.logind.lidSwitch = "suspend";
  services.logind.extraConfig = "";
  programs.bash = { promptInit = builtins.readFile ../shrc; };
  environment = {
    noXlibs = false;
    shells = [ pkgs.bash ];
    defaultPackages = with pkgs; [ ];
    systemPackages = with pkgs; [
      acpi
      git
      lm_sensors
      man-pages
      man-pages-posix
      mc
      nvi
      psmisc
      stdmanpages
      wpa_supplicant_gui
    ];
    shellAliases = { };
    homeBinInPath = true;
    variables.TOR_SOCKS_PORT = "9150";
    etc = {
      inputrc.source = ../inputrc;
      issue.source = lib.mkOverride 0 (pkgs.writeText "issue" "");
    };
    loginShellInit = ''
      [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
    '';
  };
  services.physlock = {
    enable = lib.mkForce true;
    allowAnyUser = true;
  };
}
