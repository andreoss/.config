{ config, pkgs, lib, stdenv, self, ... }: {
  config = {
    home = {
      file = { ".inputrc".source = ./../inputrc; };
      sessionVariables.NO_COLOR = "true";
    };
    programs = {
      keychain = {
        enable = true;
        enableBashIntegration = true;
        enableXsessionIntegration = true;
        extraFlags = [ "--quiet" ];
        agents = [ "ssh" ];
        keys = [ "id_rsa" ];
      };
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
      zsh = {
        enable = true;
        defaultKeymap = "viins";
        autocd = true;
        enableCompletion = true;
        enableAutosuggestions = true;
        zplug = {
          enable = true;
          plugins = [{ name = "nnao45/zsh-kubectl-completion"; }];
        };
      };
    };
  };
}
