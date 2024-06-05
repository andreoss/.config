{
  lib,
  pkgs,
  config,
  self,
  ...
}:
{
  users.mutableUsers = false;
  users.motd = "";
  users.users.root.initialHashedPassword = lib.mkForce "$6$vOuTgR3jF.ZJjRje$iWA5cET.4Ak/If9ocTp3ttRw1QjTZNmshEkLXv8r.tCI6MNYddWuOK9kqseLNct3C/MncuRnkPRlNry1KppHM/";
  users.users.root.shell = pkgs.zsh;
  users.users."${config.primaryUser.name}" = {
    uid = config.primaryUser.uid;
    initialHashedPassword = config.primaryUser.passwd;
    isNormalUser = true;
    createHome = true;
    home = config.primaryUser.home;
    linger = true;
    shell = pkgs.zsh;
  };
  users.groups = {
    uinput = { };
  };
  users.groups.wheel.members = [ config.primaryUser.name ];
  users.groups.input.members = [ config.primaryUser.name ];
  users.groups.video.members = [ config.primaryUser.name ];
  users.groups.uinput.members = [ config.primaryUser.name ];
  users.groups.disk.members = [ config.primaryUser.name ];
  services.logind.killUserProcesses = true;
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "lock";
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
    autosuggestions = {
      enable = true;
    };
    promptInit = ''
      ${builtins.readFile ../zshrc}
    '';
  };
  programs.git.enable = true;
  environment = {
    pathsToLink = [ "/share/zsh" ];
    noXlibs = false;
    shells = [
      pkgs.bash
      pkgs.zsh
    ];
    defaultPackages = with pkgs; [ ];
    systemPackages = with pkgs; [
      mc
      psmisc
      molly-guard
    ];
    shellAliases = {
      g = "git";
      "cd.." = "cd ..";
      more = "less";
      less = "less -R";
      l = "ls";
      ll = "ls -lasth";
      lh = "ls -asht";
      cx = "chmod +x";
      iec = "numfmt --to=iec";
      ping = "ping -c 4";
    };
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
}
