{ specialArgs, lib, pkgs, config, self, inputs, ... }: {
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.users.root = {
    home.stateVersion = self.config.stateVersion;
    imports = [ ./hm-root.nix ];
  };
  home-manager.users.nixos = {
    home.stateVersion = self.config.stateVersion;
    imports = [
      ../hm/emacs.nix
      ../hm/sh.nix
      ../hm/term.nix
      ../hm/browser.nix
      ../hm/xsession.nix
    ];
  };
}
