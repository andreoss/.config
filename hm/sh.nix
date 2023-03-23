{ config, pkgs, lib, stdenv, self, ... }: {
  config = {
    home = {
      file = { ".inputrc".source = ./../inputrc; };
      sessionVariables.NO_COLOR = "true";
    };
    programs = {
      bash = {
        enable = true;
        initExtra = builtins.readFile ../shrc;
      };
      direnv = {
        enable = true;
        enableBashIntegration = true;
      };
      man.enable = true;
      info.enable = true;
    };
  };
}
