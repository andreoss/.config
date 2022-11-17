{ config, pkgs, lib, stdenv, self, ... }:
{
  home.file = {
    ".inputrc".source = ./../inputrc;
  };
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
  programs.lf.enable = true;
  programs.man.enable = true;
  programs.info.enable = true;
  home.sessionVariables = {
    NO_COLOR = true;
  };
}
