{
  description = "Flakes";
  inputs = {
    emacs-d = {
      url = "github:andreoss/.emacs.d/master";
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
    nixpkgs.url = "github:nixos/nixpkgs/master";
    emacs-overlay.url = "github:nix-community/emacs-overlay/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";
    guix-overlay = {
      url = "github:foo-dogsquared/nix-overlay-guix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      inherit (nixpkgs.lib) filterAttrs traceVal;
      inherit (builtins) mapAttrs elem;
      inherit (self) outputs;
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      imports = [ ./config.nix ];
    in rec {
      legacyPackages = forAllSystems (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = false;
          overlays = [
            inputs.emacs-overlay.overlays.emacs
            inputs.guix-overlay.overlays.default
            (import ./overlays/kernel.nix)
            (import ./overlays/grub.nix)
            (import ./overlays/emacs.nix)
          ];
        });
      baseSystem = host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = legacyPackages."x86_64-linux";
          specialArgs = { inherit outputs inputs self; };
          modules = [
            ./config.nix
            inputs.home-manager.nixosModule
            inputs.guix-overlay.nixosModules.guix
            # { system.stateVersion = config.ao.stateVersion; }
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
            ./os/boot-loader.nix
          ] ++ host.modules;
        };
      homeConfigurations = {
        imports = [ ./config.nix ];
        "a" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit outputs inputs self; };
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
          ./os/fs-crypt.nix
          ./secrets/tx-hw.nix
        ];
      };
      nixosConfigurations.ts = baseSystem {
        hostname = "ts";
        modules = [
          ./secrets/fs-ts.nix
          ./secrets/ts-hw.nix
        ];
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
          # { system.stateVersion = config.ao.stateVersion; }
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
