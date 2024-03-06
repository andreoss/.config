{
  description = "Flakes";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = { url = "github:numtide/flake-utils"; };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nur.url = "github:nix-community/NUR";

    dmenu = {
      url = "github:andreoss/dmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dnscrypt-module = {
      url = "github:andreoss/dnscrypt-nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-d = {
      url = "github:andreoss/.emacs.d";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hosts = {
      url = "github:StevenBlack/hosts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kernel-overlay = {
      url = "github:andreoss/kernel-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nodm-module = {
      url = "github:andreoss/nodm-nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wfica = { url = "github:andreoss/citrix"; };

    ff-hm.url = "github:andreoss/ff-hm-module";

    urxvt-context-ext = {
      url = "github:andreoss/urxvt-context";
      flake = false;
    };

    user-js = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
    kmonad = {
      url = "git+https://github.com/kmonad/kmonad?submodules=0&dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      imports = [ ./default.nix ];
      systems = lib.systems.flakeExposed;
      lib = nixpkgs.lib;
      eachSystem = lib.genAttrs systems;
      legacyPackages = eachSystem (system:
        import nixpkgs {
          inherit system;
          config = {
            joypixels.acceptLicense = true;
            allowUnfree = true;
            permittedInsecurePackages = [ "mupdf-1.17.0" ];
          };
          overlays = [
            inputs.nur.overlay
            inputs.emacs-d.overlays.default
            inputs.kernel-overlay.overlays.${system}.default
            (final: prev:
              let pkgs_ = import nixpkgs { inherit system; };
              in {
                grub2 = (pkgs_.grub2.override { }).overrideAttrs
                  (oldattrs: rec {
                    patches = [
                      #./overlays/01-quite.patch
                      #./overlays/02-no-uuid.patch
                      #./overlays/03-quite.patch
                    ];
                  });
              })
          ];
        });
      mkSystemGeneric = host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = legacyPackages."x86_64-linux";
          specialArgs = {
            inputs = inputs;
            overlays = legacyPackages."x86_64-linux".overlays;
            cfg = host.config;
          };
          modules = [
            ./default.nix
            host.config
            inputs.nodm-module.nixosModules.default
            inputs.dnscrypt-module.nixosModules.default
            { networking.dns-crypt.enable = true; }
            inputs.home-manager.nixosModule
            inputs.hosts.nixosModule
            { networking.stevenBlackHosts.enable = true; }
            { networking.hostName = host.hostname; }
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
            ./os/console.nix
          ];
        };
      mkSystem = host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = legacyPackages."x86_64-linux";
          specialArgs = {
            inputs = inputs;
            overlays = legacyPackages."x86_64-linux".overlays;
            cfg = host.config;
          };
          modules = [
            ./default.nix
            host.config
            { time.timeZone = "America/New_York"; }
            { networking.stevenBlackHosts.enable = true; }
            { networking.hostName = host.hostname; }
            inputs.nodm-module.nixosModules.default
            inputs.dnscrypt-module.nixosModules.default
            { networking.dns-crypt.enable = true; }
            inputs.home-manager.nixosModule
            inputs.hosts.nixosModule
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
            ./os/vpn.nix
            ./os/network.nix
            ./os/i18n.nix
            ./os/boot.nix
            ./os/console.nix
            {
              system.autoUpgrade = {
                enable = true;
                flake = inputs.self.outPath;
                flags =
                  [ "--update-input" "nixpkgs" "--no-write-lock-file" "-L" ];
                dates = "02:00";
                randomizedDelaySec = "45min";
              };
            }
          ];
        };
    in rec {

      nixosConfigurations."ps" = mkSystem {
        hostname = "ps";
        config = import ./secrets { lib = lib; };
        modules = [
          ./secrets/3
          ./os/boot-grub-efi.nix
          ./os/btrfs-swap.nix
          ./os/containers.nix
        ];
      };

      nixosConfigurations."v" = mkSystemGeneric {
        hostname = "v";
        config = {
          config.hostId = "000a";
          config.primaryUser = {
            name = "v";
            authorizedKeys = [ ];
            uid = 1338;
            home = "/user";
            passwd =
              "$6$wQMDzeSSe0JgUStV$oYkJz.j6hHI8bjUxX5Pk0adAF6aj7Zzjo.3YVMl.bUUqDNAO6gTAiPbnf8enCIqL2M7LYXlKEEDZDNfyXKbb3.";
          };
          config.minimalInstallation = false;
          config.autoLogin = true;
          config.preferPipewire = true;
          config.dpi = 140;
          config.features = [ "multimedia" "web" "office" "vm" ];
        };
        modules = [
          { time.timeZone = "Europe/Moscow"; }
          ./os/boot-grub-efi.nix
          ./os/btrfs.nix
          ./os/btrfs-swap.nix
        ];
      };

      nixosConfigurations.livecd = let
        cfg = {
          config.hostId = "ffff";
          config.primaryUser = {
            name = "nixos";
            authorizedKeys = [ ];
            uid = 1000;
            home = "/user";
            passwd = "nixos";
          };
          config.minimalInstallation = true;
          config.autoLogin = true;
          config.autoLock.enable = false;
          config.preferPipewire = true;
          config.features = [ "livecd" ];
        };
      in nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = legacyPackages."x86_64-linux";
        specialArgs = {
          inherit inputs self;
          cfg = cfg;
        };
        modules = [
          ./default.nix
          cfg
          inputs.nodm-module.nixosModules.default
          inputs.dnscrypt-module.nixosModules.default
          { networking.dns-crypt.enable = true; }
          inputs.home-manager.nixosModule
          ./os/configuration.nix
          ./os/console.nix
          ./os/hm.nix
          ./os/hw.nix
          ./os/iso.nix
          ./os/network.nix
          ./os/nix.nix
          ./os/xserver.nix
        ];
      };
    };
}
