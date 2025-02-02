{
  description = "Flakes";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
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

    wfica = {
      url = "github:andreoss/citrix";
    };

    ff-hm = {
      url = "github:andreoss/ff-hm-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    urxvt-context-ext = {
      url = "github:andreoss/urxvt-context";
      flake = false;
    };

    user-js = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      home-manager,
      nixos-hardware,
      ghostty,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.nixosConfigurations =
        let
          mkSystem =
            host:
            nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs self;
                cfg = host.config;
                overlays = host.overlays;
              };
              modules =
                [
                  {
                    nixpkgs.config.allowUnfree = true;
                    nixpkgs.overlays = host.overlays ++ [
                      inputs.nur.overlay
                      inputs.emacs-d.overlays.default
                      # inputs.kernel-overlay.overlays."x86_64-linux".default
                    ];
                  }
                  host.config
                  ./default.nix
                  { time.timeZone = "America/New_York"; }
                  { networking.stevenBlackHosts.enable = true; }
                  { networking.hostName = host.hostname; }
                  inputs.nodm-module.nixosModules.default
                  inputs.dnscrypt-module.nixosModules.default
                  { networking.dns-crypt.enable = true; }
                  inputs.home-manager.nixosModule
                  inputs.hosts.nixosModule
                ]
                ++ host.modules
                ++ [
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
                      flags = [
                        "--update-input"
                        "nixpkgs"
                        "--no-write-lock-file"
                        "-L"
                      ];
                      dates = "02:00";
                      randomizedDelaySec = "45min";
                    };
                  }
                ];
            };
        in
        {
          "ss" = mkSystem {
            hostname = "ss";
            config = import ./secrets;
            overlays = [ ];
            modules = [
              {
                config.preferedLocalIp = "192.168.0.16";
                config.dpi = 99;
              }
              ./secrets/2
              ./os/boot-grub-efi.nix
              ./os/btrfs-swap.nix
            ];
          };
          "ps" = mkSystem {
            hostname = "ps";
            config = import ./secrets;
            overlays = [ ];
            modules = [
              {
                config.kernel = "linuxPackages";
                config.preferedLocalIp = "192.168.0.32";
                config.dpi = 120;
              }
              ./secrets/3
              ./os/boot-grub-efi.nix
              ./os/btrfs-swap.nix
              ./os/containers.nix
            ];
          };
        };
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [
              inputs.nur.overlay
              inputs.emacs-d.overlays.default
              # inputs.kernel-overlay.overlays.default
            ];
            config = {
              allowUnfree = true;
            };
          };
        };
      flake.overlays.default = (
        inputs.nixpkgs.lib.composeManyExtensions [
          inputs.nur.overlay
          inputs.emacs-d.overlays.default
          # inputs.kernel-overlay.overlays.default
        ]
      );
    };
}
