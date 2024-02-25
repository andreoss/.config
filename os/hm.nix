{ specialArgs, config, ... }: {
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.users.root = {
    home.stateVersion = config.ao.stateVersion;
    imports = [ ../config.nix ./hm-root.nix ];
  };
  home-manager.users."${config.ao.primaryUser.name}" = {
    nixpkgs.overlays = specialArgs.overlays;
    home.stateVersion = config.ao.stateVersion;
    imports = [
      ../modules/development
      ../modules/multimedia.nix
      ../modules/web.nix
      ../modules/office.nix
      ../hm/base.nix
      ../hm/home.nix
      ../hm/mail.nix
      ../hm/sh.nix
      ../hm/term.nix
      ../hm/xsession-base.nix
      specialArgs.inputs.emacs-d.nixosModules.home-manager
      ../hm/xsession.nix
      ../hm/work.nix
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
