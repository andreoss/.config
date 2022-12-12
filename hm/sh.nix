{ config, pkgs, lib, stdenv, self, ... }: {
  config = {
    home.file = { ".inputrc".source = ./../inputrc; };
    programs.bash = {
      enable = true;
      enableVteIntegration = true;
      initExtra = builtins.readFile ../shrc;
    };
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
    };
    programs.jq.enable = true;
    programs.man.enable = !config.mini;
    programs.info.enable = !config.mini;
    home.sessionVariables.NO_COLOR = true;
  };
}
