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

### Check bootloader type
```console
[ -d /sys/firmware/efi/efivars ] && echo "UEFI" || echo "Legacy"
```

### Clone repo
```
sudo -s
nix-shell -p git tmux
tmux
git config --global http.version HTTP/1.1
git config --global http.postBuffer 30m
git clone --depth 1 https://github.com/andreoss/.config
cd .config
```

### Format disk
```
export HOST_ID=10
./scripts/format-disk.sh -f -C -E -L gpt -d /dev/nvme0n1 -H "$HOST_ID" -F btrfs
./scripts/format-disk.sh -m -C -E -L gpt -d /dev/nvme0n1 -H "$HOST_ID" -F btrfs
git add -f secrets/system-000a
```
### Install

```
nixos-install --flake '.#v' --root /mnt-2 --no-root-passwd
```
### Add LUKS key
```console
cryptsetup luksAddKey  --key-file secrets/system-000a /dev/nvme0n1p2
```
### Unmount & reboot
```
./scripts/format-disk.sh -u -C -E -L gpt -d /dev/nvme0n1 -H "$HOST_ID" -F btrfs
reboot
```
