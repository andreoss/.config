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

## Typical installation from NixOS Minimal Live CD

```
sudo -s
nix-shell -p git tmux
tmux
git config --global http.version HTTP/1.1
git config --global http.postBuffer 30m
git clone --depth 1 https://github.com/andreoss/.config
cd .config

export HOST_ID=10
./scripts/format-disk.sh -f -C -E -L gpt -d /dev/sda -H "$HOST_ID" -F btrfs
./scripts/format-disk.sh -m -C -E -L gpt -d /dev/sda -H "$HOST_ID" -F btrfs
git add -f secrets/system-000a
nixos-install --flake '.#v' --root /mnt-2 --no-root-passwd
cryptsetup luksAddKey  --key-file secrets/system-000a /dev/sda2
./scripts/format-disk.sh -u -C -E -L gpt -d /dev/sda -H "$HOST_ID" -F btrfs
reboot
```
