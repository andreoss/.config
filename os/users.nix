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
  users.groups = {
    uinput = { };
    tunnel = { };
  };
  users.groups.wheel.members = [ config.ao.primaryUser.name ];
  users.groups.input.members = [ config.ao.primaryUser.name ];
  users.groups.video.members = [ config.ao.primaryUser.name ];
  users.groups.uinput.members = [ config.ao.primaryUser.name ];
  services.logind.killUserProcesses = true;
  services.logind.lidSwitch = "suspend";
  services.logind.extraConfig = "";
  programs.bash = {
    promptInit = ''
      ${builtins.readFile ../shrc}
      ${builtins.readFile ../bashrc}
    '';
  };
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    autosuggestions = { enable = true; };
    promptInit = ''
      ${builtins.readFile ../zshrc}
    '';
  };
  environment = {
    pathsToLink = [ "/share/zsh" ];
    noXlibs = false;
    shells = [ pkgs.bash pkgs.zsh ];
    defaultPackages = with pkgs; [ ];
    systemPackages = with pkgs; [
      openvpn
      wireguard-tools
      zsh
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
      links2
      fbterm
      jfbpdf
      fbida
      fbcat
      molly-guard
    ];
    shellAliases = { };
    homeBinInPath = true;
    variables.TOR_SOCKS_PORT = "9150";
    variables.EDITOR = "vi";
    variables.NIX_SHELL_PRESERVE_PROMPT = "1";
    etc = {
      inputrc.source = ../inputrc;
      issue.source = lib.mkOverride 0 (pkgs.writeText "issue" "");
    };
    loginShellInit = ''
      [ -d "$HOME/.nix-profile" ] || /nix/var/nix/profiles/per-user/$USER/home-manager/activate &> /dev/null
    '';
  };
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;
  services.physlock = {
    enable = lib.mkForce true;
    allowAnyUser = true;
  };
}
