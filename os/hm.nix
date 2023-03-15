{ specialArgs, lib, pkgs, config, ... }:
let l = config.ao.primaryUser.languages;
in {
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.users.root = {
    home.stateVersion = config.ao.stateVersion;
    imports = [ ../config.nix ./hm-root.nix ];
  };
  home-manager.users."${config.ao.primaryUser.name}" = {
    nixpkgs.overlays = [ specialArgs.inputs.emacs-d.overlays.default ];
    home.stateVersion = config.ao.stateVersion;
    imports = [
      ../config.nix
      ../hm/base.nix
      ../hm/home.nix
      ../hm/mail.nix
      ../hm/emacs.nix
      ../hm/sh.nix
      ../hm/term.nix
      ../hm/vcs.nix
      ../hm/browser.nix
    ] ++ (lib.optionals (config.ao.primaryUser.graphics) [
      ../hm/xsession-base.nix
      ../hm/xsession.nix
    ]) ++ (lib.optionals (!config.mini && l.java) [ ../hm/java.nix ])
      ++ (lib.optionals (!config.mini && l.scala) [ ../hm/scala.nix ])
      ++ (lib.optionals (!config.mini && l.perl) [ ../hm/perl.nix ]);
  };
}
