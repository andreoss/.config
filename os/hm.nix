{ specialArgs, lib, pkgs, config, self, inputs, ... }: {
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.users.root = {
    home.stateVersion = self.config.stateVersion;
    imports = [ ./hm-root.nix ];
  };
  home-manager.users."${self.config.primaryUser.name}" = {
    home.stateVersion = self.config.stateVersion;
    imports = [
      ../nixpkgs/home.nix
      ../nixpkgs/emacs.nix
      ../nixpkgs/sh.nix
      ../nixpkgs/term.nix
      ../nixpkgs/vcs.nix
      ../nixpkgs/java.nix
      ../nixpkgs/browser.nix
      ../nixpkgs/xsession.nix
    ] ++ lib.optional (self.config.androidDev) [ ../nixpkgs/android.nix ];
  };
}
