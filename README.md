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


##
```
 $ export HOST_ID=dead # hexidecimal number (0000-ffff)
 $ sudo ./scripts/format-disk.sh -f -C -E -L msdos -d /dev/sda -H "$HOST_ID" -F btrfs
 $ sudo ./scripts/format-disk.sh -m -C -E -L msdos -d /dev/sda -H "$HOST_ID" -F btrfs
 $ sudo chown -R "$USER" secrets/
 $ git add secrets/*-"$HOST_ID"
 $ sudo nixos-install --flake .#"$HOST_ID" --root /mnt-2 --no-root-passwd
 $ sudo ./scripts/format-disk.sh -u -C -E -L msdos -d /dev/sda -H "$HOST_ID" -F btrfs
 $ sudo cryptsetup luksAddKey  --key-file secrets/boot-"$HOST_ID" /dev/sdb1
```
