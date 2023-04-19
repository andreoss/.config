{
  description = "Flakes";
  inputs = {
    dmenu.url = "github:andreoss/dmenu";
    dnscrypt-module.url = "github:andreoss/dnscrypt-nixos-module";
    emacs-d.url = "github:andreoss/.emacs.d";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    guix-overlay.url = "github:foo-dogsquared/nix-overlay-guix";
    home-manager.url = "github:nix-community/home-manager";
    hosts.url = "github:StevenBlack/hosts";
    kernel-overlay.url = "github:andreoss/kernel-overlay";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nodm-module.url = "github:andreoss/nodm-nixos-module";
    wfica.url = "github:andreoss/citrix";
    password-store = {
      url = "git+ssh://git@github.com/andreoss/.password-store.git";
      flake = false;
    };
    urxvt-context-ext = {
      url = "github:andreoss/urxvt-context";
      flake = false;
    };
    user-js = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      imports = [ ./config.nix ];
      systems = lib.systems.flakeExposed;
      lib = nixpkgs.lib;
      eachSystem = lib.genAttrs systems;
      options = builtins.fromTOML (builtins.readFile ./secrets/options.toml);
      legacyPackages = eachSystem (system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = false;
            permittedInsecurePackages = [ "mupdf-1.17.0" ];
          };
          overlays = [
            inputs.emacs-d.overlays.default
            inputs.kernel-overlay.overlays.${system}.default
            (self: super:
              let
                nixpkgs-mesa = builtins.fetchTarball {
                  url =
                    "https://github.com/nixos/nixpkgs/archive/bdac777becdbb8780c35be4f552c9d4518fe0bdb.tar.gz";
                  sha256 =
                    "sha256:18hi3cgagzkrxrwv6d9yjazqg5q2kiacjn3hhb94j4gs6c6kdxrk";
                };
              in {
                mesa_drivers =
                  (import nixpkgs-mesa { inherit system; }).mesa_drivers;
              })
            (final: prev:
              let pkgs_ = import nixpkgs { inherit system; };
              in {
                grub2 = (pkgs_.grub2.override { }).overrideAttrs
                  (oldattrs: rec {
                    patches = [
                      ./overlays/01-quite.patch
                      ./overlays/02-no-uuid.patch
                      ./overlays/03-quite.patch
                    ];
                  });
              })
          ];
        });
      baseSystem = host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = legacyPackages."x86_64-linux";
          specialArgs = { inherit inputs self; };
          modules = [
            { system.stateVersion = options.main.stateVersion; }
            ./config.nix
            inputs.nodm-module.nixosModules.default
            inputs.dnscrypt-module.nixosModules.default
            inputs.home-manager.nixosModule
            inputs.guix-overlay.nixosModules.guix
            inputs.hosts.nixosModule
            { networking.stevenBlackHosts.enable = true; }
            { networking.hostName = host.hostname; }
            { services.guix.enable = false; }

          ] ++ host.modules ++ [
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
          ];
        };
    in rec {
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
              config.home.stateVersion = options.main.stateVersion;
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
          inputs.nixos-hardware.nixosModules.${options.tx.model}
          ./secrets/tx-hw.nix
          ./os/fs-crypt.nix
          ./os/boot-loader.nix
          ./os/containers.nix
        ];
      };
      nixosConfigurations.ts = baseSystem {
        hostname = "ts";
        modules = [
          inputs.nixos-hardware.nixosModules.${options.ts.model}
          ./secrets/fs-ts.nix
          ./secrets/ts-hw.nix
          ./os/boot-loader.nix
        ];
      };
      nixosConfigurations.ss = baseSystem {
        hostname = "ss";
        modules = [
          inputs.nixos-hardware.nixosModules.${options.ss.model}
          ./secrets/ss-hw.nix
          ./os/boot-grub.nix
          ./secrets/tx-hw.nix
          ./os/containers.nix
        ];
      };
      nixosConfigurations.tq = baseSystem {
        hostname = "tq";
        modules = [ ./os/fs-legacy.nix ./os/boot-grub.nix ];
      };
      nixosConfigurations.livecd = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        pkgs = legacyPackages."x86_64-linux";
        modules = [
          inputs.nodm-module.nixosModules.default
          inputs.dnscrypt-module.nixosModules.default
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
