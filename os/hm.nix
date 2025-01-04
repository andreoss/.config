{
  specialArgs,
  lib,
  pkgs,
  config,
  ...
}:
let
  isOn = (x: (builtins.elem x config.features));
in
{
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.useGlobalPkgs = true;
  home-manager.verbose = true;
  home-manager.backupFileExtension = "backup";
  home-manager.sharedModules = [
    {
      home.sessionVariables = {
        NIX_SHELL_PRESERVE_PROMPT = 1;
      };
    }
  ];
  home-manager.users.root = {
    home.stateVersion = config.stateVersion;
    imports = [
      {
        home.packages = with pkgs; [
          usbutils
          pciutils
          ethtool
        ];
      }
    ];
  };
  home-manager.users."${config.primaryUser.name}" = {
    home.stateVersion = config.stateVersion;
    imports =
      [
        ../default.nix
        specialArgs.cfg
        specialArgs.inputs.emacs-d.nixosModules.home-manager
        specialArgs.inputs.ff-hm.homeManagerModules.default
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
      ]
      ++ (lib.optionals (isOn "work") [ ../hm/work.nix ])
      ++ (lib.optionals (isOn "email") [ ../hm/mail.nix ])
      ++ [
        {
          home.firefox = {
            enable = true;
            homePage = "https://opennet.ru";
          };
        }
        {
          home.development = {
            cxx.enable = isOn "cxx";
            haskell.enable = isOn "haskell";
            java.enable = isOn "java";
            js.enable = isOn "js";
            lisp.enable = isOn "lisp";
            perl.enable = isOn "perl";
            rust.enable = isOn "rust";
            scala.enable = isOn "scala";
          };
        }
        { home.multimedia.enable = isOn "multimedia"; }
        { home.office.enable = isOn "office"; }
        { home.web.enable = isOn "web"; }
      ];
  };
}
