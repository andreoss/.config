{ config, pkgs, lib, stdenv, self, ... }: {
  config = {
    home.file = { ".inputrc".source = ./../inputrc; };
    programs.bash = {
      enable = true;
      initExtra = builtins.readFile ../shrc;
    };
    programs.zsh = {
      enable = true;
      defaultKeymap = "viins";
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      initExtra = builtins.readFile ../zshrc;
    };
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
    };
    programs.jq.enable = true;
    programs.man.enable = !config.mini;
    programs.info.enable = !config.mini;
    home.sessionVariables.NO_COLOR = 1;
    programs.nix-index = {
      enable = true;
      enableBashIntegration  = true;
      enableZshIntegration  = true;
    };
  };
}
