{
  description = "Flakes";
  inputs = {
    emacsd = {
      url = "github:andreoss/.emacs.d/master";
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
      notBroken = x: !(x.meta.broken or false);
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    rec {
      config = {
        stateVersion = "22.11";
        fileSystems = {
          btrfsOptions = [ "compress=zstd" ];
        };
        androidDev = false;
        pipewireReplacesPulseaudio = true;
        primaryUser = {
          name = "a";
          home = "/user";
          autoLogin = true;
          emacsFromNix = true;
          graphics = true;
        };
      };
      legacyPackages = forAllSystems (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = false;
          overlays = [
            inputs.emacs-overlay.overlays.emacs
            inputs.guix-overlay.overlays.default
          ];
        }
      );
      homeConfigurations = {
        "${self.config.primaryUser.name}" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit outputs inputs self; };
          modules = [
            {
              config.home.username = self.config.primaryUser.name;
              config.home.homeDirectory = self.config.primaryUser.home;
              config.home.stateVersion = self.config.stateVersion;
            }
            ./nixpkgs/browser.nix
            ./nixpkgs/emacs.nix
            ./nixpkgs/home.nix
            ./nixpkgs/java.nix
            ./nixpkgs/sh.nix
            ./nixpkgs/term.nix
            ./nixpkgs/vcs.nix
            ./nixpkgs/xsession.nix
          ];
        };
      };
      nixosConfigurations.tx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = legacyPackages."x86_64-linux";
        specialArgs = {inherit inputs self;};
        modules = [
          inputs.home-manager.nixosModule
          inputs.guix-overlay.nixosModules.guix
          {
            system.stateVersion = self.config.stateVersion;
          }
          {
            services.guix.enable = true;
            services.guix.package = inputs.guix-overlay.packages.x86_64-linux.guix;
          }
          ./os/hm.nix
          ./os/hardware-configuration-generic-crypt.nix
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
        ];
      };
      nixosConfigurations.livecd = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        pkgs = legacyPackages."x86_64-linux";
        modules = [
          inputs.home-manager.nixosModule
          {
            system.stateVersion = self.config.stateVersion;
          }
          ./os/hm.nix
          ./os/i18n.nix
          ./os/iso.nix
          ./os/network.nix
          ./os/nix.nix
          ./os/xserver.nix
          ./os/users.nix
          ./os/audio.nix
          ./os/hw.nix
        ];
      };
    };
}
