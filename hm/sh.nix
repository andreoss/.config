{
  config,
  pkgs,
  lib,
  stdenv,
  self,
  ...
}:
{
  config = {
    home = {
      file = {
        ".inputrc".source = ./../inputrc;
      };
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
        history = {
          extended = true;
          ignoreDups = true;
          ignorePatterns = [
            "rm *"
            "pkill *"
          ];
          save = 10000000;
          size = 10000000;
        };
        defaultKeymap = "viins";
        autocd = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        initExtra = ''
          ${builtins.readFile ../shrc}
          ${builtins.readFile ../zshrc}
        '';
        shellAliases = {
          "g" = "git";
        };
        shellGlobalAliases = {
          "L" = "| less";
        };
        syntaxHighlighting = {
          highlighters = [ "brackets" ];
        };
      };
    };
  };
}
