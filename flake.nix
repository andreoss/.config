{
  description = "Flakes";
  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = [ "https://kernel-overlay.cachix.org" ];
    extra-trusted-public-keys = [
      "kernel-overlay.cachix.org-1:rUvSa2sHn0a7RmwJDqZvijlzZHKeGvmTQfOUr2kaxr4="
    ];
  };
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    kernel-overlay.url = "git+ssh://git@github.com/andreoss/kernel-overlay.git";
    emacs-d = {
      url = "github:andreoss/.emacs.d/master";
      flake = false;
    };
    dmenu.url = "github:andreoss/dmenu/master";
    jc-themes = {
      url = "gitlab:andreoss/jc-themes/master";
      flake = false;
    };
    elisp-autofmt = {
      url = "git+https://codeberg.org/ideasman42/emacs-elisp-autofmt.git";
      flake = false;
    };
    password-store = {
      url = "git+ssh://git@github.com/andreoss/.password-store.git";
      flake = false;
    };
    urxvt-context-ext = {
      url = "github:andreoss/urxvt-context/master";
      flake = false;
    };
    hosts = {
      url = "github:StevenBlack/hosts/master";
      flake = false;
    };
    user-js = {
      url = "github:arkenfox/user.js/master";
      flake = false;
    };
    emacs-overlay = { url = "github:nix-community/emacs-overlay/master"; };
    guix-overlay = { url = "github:foo-dogsquared/nix-overlay-guix"; };
    home-manager = { url = "github:nix-community/home-manager"; };
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-22.11"; };
    wfica = { url = "github:andreoss/citrix/master"; };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      imports = [ ./config.nix ];
      systems = lib.systems.flakeExposed;
      lib = nixpkgs.lib;
      eachSystem = lib.genAttrs systems;
    in rec {
      legacyPackages = eachSystem (system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = false;
            permittedInsecurePackages = [ "mupdf-1.17.0" ];
          };
          overlays = [ inputs.kernel-overlay.overlays.default ];
        });
      baseSystem = host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = legacyPackages."x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            ./config.nix
            inputs.home-manager.nixosModule
            inputs.guix-overlay.nixosModules.guix
            { networking.hostName = host.hostname; }
            { services.guix.enable = false; }
            ./os/hm.nix
            ./os/nix.nix
            ./os/configuration.nix
            ./os/hw.nix
            ./os/security.nix
            ./os/audio.nix
            ./os/users.nix
            ./os/virtualisation.nix
            ./os/xserver.nix
            ./os/network.nix
            ./os/i18n.nix
            ./os/boot.nix
          ] ++ host.modules;
        };
      homeConfigurations = {
        imports = [ ./config.nix ];
        "a" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs self; };
          modules = [
            ./config.nix
            {
              config.home.username = "a";
              config.home.homeDirectory = "/user";
              config.home.stateVersion = "23.05";
            }
            ./hm/browser.nix
            ./hm/emacs.nix
            ./hm/mail.nix
            ./hm/home.nix
            ./hm/java.nix
            ./hm/perl.nix
            ./hm/scala.nix
            ./hm/sh.nix
            ./hm/term.nix
            ./hm/vcs.nix
            ./hm/xsession.nix
          ];
        };
      };
      nixosConfigurations.tx = baseSystem {
        hostname = "tx";
        modules = [
          ./secrets/tx-hw.nix
          ./os/fs-crypt.nix
          ./os/boot-loader.nix
          ./os/containers.nix
        ];
      };
      nixosConfigurations.ts = baseSystem {
        hostname = "ts";
        modules =
          [ ./secrets/fs-ts.nix ./secrets/ts-hw.nix ./os/boot-loader.nix ];
      };
      nixosConfigurations.ss = baseSystem {
        hostname = "ss";
        modules = [
          {
            config.mini = true;
            config.ao.primaryUser.office = false;
          }
          ./secrets/ss-hw.nix
          ./os/boot-grub.nix
        ];
      };
      nixosConfigurations.tq = baseSystem {
        hostname = "tq";
        modules = [ ./os/fs-legacy.nix ./os/boot-grub-uefi.nix ];
      };
      nixosConfigurations.livecd = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        pkgs = legacyPackages."x86_64-linux";
        modules = [
          ./config.nix
          {
            config.isLivecd = true;
            config.mini = true;
            config.ao.primaryUser.name = "nixos";
          }
          inputs.home-manager.nixosModule
          ./os/xserver.nix
          ./os/audio.nix
          ./os/configuration.nix
          ./os/hm-iso.nix
          ./os/hw.nix
          ./os/i18n.nix
          ./os/iso.nix
          ./os/network.nix
          ./os/nix.nix
        ];
      };
    };
}
