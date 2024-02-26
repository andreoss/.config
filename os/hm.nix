{ specialArgs, lib, pkgs, config, ... }: {
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.users.root = {
    home.stateVersion = config.stateVersion;
    imports = [{
      home.packages = with pkgs; [ nvi pciutils usbutils ];
      home.sessionVariables = { NIX_SHELL_PRESERVE_PROMPT = 1; };
    }];
  };
  home-manager.users."${config.primaryUser.name}" = {
    nixpkgs.overlays = specialArgs.overlays;
    home.stateVersion = config.stateVersion;
    imports = [
      ../default.nix
      specialArgs.inputs.emacs-d.nixosModules.home-manager
      ../modules/development
      ../modules/multimedia.nix
      ../modules/web.nix
      ../modules/office.nix
      ../hm/base.nix
      ../hm/home.nix
      ../hm/sh.nix
      ../hm/term.nix
      ../hm/xsession-base.nix
      ../hm/xsession.nix
    ] ++ (lib.optionals (builtins.elem "work" config.features)
      [ ../hm/work.nix ])
      ++ (lib.optionals (builtins.elem "email" config.features)
        [ ../hm/mail.nix ]) ++ [
          {
            home.development = {
              cxx.enable = true;
              haskell.enable = true;
              java.enable = true;
              js.enable = true;
              lisp.enable = true;
              perl.enable = true;
              rust.enable = true;
              scala.enable = true;
            };
          }
          { home.multimedia.enable = true; }
          { home.web.enable = true; }
          { home.office.enable = true; }
        ];
  };
}
