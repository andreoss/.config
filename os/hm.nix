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
      ../modules/lisp.nix
      ../modules/haskell.nix
      ../modules/multimedia.nix
      ../modules/web.nix
      ../modules/perl.nix
      { home.multimedia.enable = true; }
      { home.web.enable = true; }
      ../config.nix
      ../hm/base.nix
      ../hm/home.nix
      ../hm/mail.nix
      ../hm/emacs.nix
      ../hm/sh.nix
      ../hm/term.nix
      ../hm/vcs.nix
    ] ++ (lib.optionals (config.ao.primaryUser.graphics) [
      ../hm/xsession-base.nix
      ../hm/xsession.nix
    ]) ++ (lib.optionals (!config.mini && l.java) [ ../hm/java.nix ])
      ++ (lib.optionals (!config.mini && l.scala) [ ../hm/scala.nix ]);
  };
}
