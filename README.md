# .config

## Upgrade existing NixOS installation

```
sudo nixos-rebuild switch --flake '.#' --install-bootloader --upgrade 

```

## Upgrade home-manager configuration (for non-NixOS systems)

```
home-manager switch --flake .
```

## Build live CD

```
 nix build path:.\#nixosConfigurations.livecd.config.system.build.isoImage
 sudo dd if=result/iso/nixos...iso of=/dev/sdb status=progress
```

