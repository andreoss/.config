{ specialArgs, lib, pkgs, config, self, inputs, ... }: {
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.users.root = {
    home.stateVersion = config.ao.stateVersion;
    imports = [
      ../config.nix
      ./hm-root.nix
    ];
  };
  home-manager.users.nixos = {
    home.stateVersion = config.ao.stateVersion;
    imports = [
      ../config.nix
      ../hm/emacs.nix
      ../hm/sh.nix
      ../hm/term.nix
      ../hm/browser.nix
      ../hm/xsession.nix
    ];
  };
}
