{ specialArgs, lib, pkgs, config, self, inputs, ... }: {
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.users.root = {
    home.stateVersion = self.config.stateVersion;
    imports = [ ./hm-root.nix ];
  };
  home-manager.users."${self.config.primaryUser.name}" = {
    home.stateVersion = self.config.stateVersion;
    imports = [
      ../hm/home.nix
      ../hm/mail.nix
      ../hm/emacs.nix
      ../hm/sh.nix
      ../hm/term.nix
      ../hm/vcs.nix
      ../hm/java.nix
      ../hm/browser.nix
      ../hm/xsession.nix
      ../hm/java.nix
      ../hm/perl.nix
      ../hm/scala.nix
    ] ++ (lib.optional (self.config.primaryUser.languages.android) [ ../hm/android.nix ])
    ;
  };
}
