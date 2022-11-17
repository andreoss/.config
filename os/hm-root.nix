{ config, pkgs, lib, stdenv, ... }:
{
  home.packages = with pkgs; [ nvi pciutils usbutils ];
  home.sessionVariables = { NIX_SHELL_PRESERVE_PROMPT = 1; };
  programs.bash = {
    enable = true;
    initExtra = ''set -o vi; export PS1=" # "; '';
  };
}
