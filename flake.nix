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

    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };

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
      options = builtins.fromTOML (builtins.readFile ./secrets/options.toml);
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
          };
          modules = [
            ./default.nix
            { system.stateVersion = options.main.stateVersion; }
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
          ];
        };
      mkSystem = host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          pkgs = legacyPackages."x86_64-linux";
          specialArgs = {
            inputs = inputs;
            overlays = legacyPackages."x86_64-linux".overlays;
          };
          modules = [
            ./default.nix
            ./secrets
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
      nixosConfigurations.tx = mkSystem {
        hostname = "tx";
        modules = [
          inputs.nixos-hardware.nixosModules.${options.tx.model}
          ./secrets/tx-hw.nix
          ./os/fs-crypt.nix
          ./os/boot-loader.nix
          ./os/containers.nix
        ];
      };
      nixosConfigurations.ts = mkSystem {
        hostname = "ts";
        modules = [
          inputs.nixos-hardware.nixosModules.${options.ts.model}
          ./secrets/fs-ts.nix
          ./secrets/ts-hw.nix
          ./os/boot-loader.nix
        ];
      };
      nixosConfigurations.ss = mkSystem {
        hostname = "ss";
        modules = [
          inputs.nixos-hardware.nixosModules.${options.ss.model}
          ./secrets/ss-hw.nix
          ./os/boot-grub.nix
          ./secrets/tx-hw.nix
          ./os/containers.nix
        ];
      };

      nixosConfigurations.dx = mkSystem {
        hostname = "dx";
        modules = [
          ./secrets/dx
          ./os/boot-loader.nix
          ./secrets/tx-hw.nix
          ./os/containers.nix
        ];
      };

      nixosConfigurations."ps" = mkSystem {
        hostname = "ps";
        modules = [
          ./secrets/3
          ./os/boot-grub-efi.nix
          ./os/btrfs-swap.nix
          ./os/containers.nix
        ];
      };

      nixosConfigurations."v" = mkSystemGeneric {
        hostname = "v";
        modules = [
          {
            config.hostId = "000a";
            config.primaryUser = {
              name = "v";
              authorizedKeys = [ ];
              uid = 1338;
              home = "/user";
              passwd = "*";
            };
            config.minimalInstallation = false;
            config.autoLogin = true;
            config.preferPipewire = true;
            config.features = [ ];

          }
          { time.timeZone = "Europe/Moscow"; }
          ./os/boot-grub-efi.nix
          ./os/btrfs.nix
          ./os/btrfs-swap.nix
        ];
      };

      nixosConfigurations.rr = mkSystem {
        hostname = "rr";
        modules = [
          inputs.nixos-hardware.nixosModules.${options.ss.model}
          ./secrets/rr
          ./os/boot-loader.nix
          ./secrets/tx-hw.nix
          ./os/containers.nix
        ];
      };

      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        modules = [
          inputs.home-manager.nixosModule
          ./os/wsl.nix
          ./os/nix.nix
          ./os/i18n.nix
        ];
      };
      nixosConfigurations.livecd = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs self; };
        pkgs = legacyPackages."x86_64-linux";
        modules = [
          ./default.nix
          inputs.nodm-module.nixosModules.default
          inputs.dnscrypt-module.nixosModules.default
          { networking.dns-crypt.enable = true; }
          {
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
            config.preferPipewire = true;
            config.features = [ ];
          }
          inputs.home-manager.nixosModule
          ./os/iso.nix
          ./os/xserver.nix
          ./os/audio.nix
          ./os/configuration.nix
          ./os/hm.nix
          ./os/hw.nix
          ./os/network.nix
          ./os/nix.nix
        ];
      };
    };
}
