{ lib, ... }:
{
  # Auto-discover every *.nix module in this directory. Drop a new file in
  # here and it is activated automatically -- no need to edit import lists.
  #
  # `exclude` lists modules that are intentionally NOT auto-activated:
  #  - palette.nix        : a color value, not a module (imported directly by boot.nix)
  #  - per-host modules   : boot-grub-efi.nix, btrfs-swap.nix, containers.nix
  #                          are wired per-host via flake.nix `host.modules`.
  #  - inactive/legacy    : boot-grub.nix (conflicts with the EFI loader),
  #                          boot-loader.nix, btrfs.nix, fonts.nix, gnome.nix,
  #                          guix.nix, hm-nixos.nix, hm-root.nix, iso.nix,
  #                          kmonad.nix, qemu.nix -- previously not wired in.
  # Remove an entry here to activate that module everywhere.
  imports = (import ../lib/imports.nix { inherit lib; }).importDir {
    exclude = [
      "palette.nix"
      "boot-grub-efi.nix"
      "boot-grub.nix"
      "btrfs-swap.nix"
      "containers.nix"
      "boot-loader.nix"
      "btrfs.nix"
      "fonts.nix"
      "gnome.nix"
      "guix.nix"
      "hm-nixos.nix"
      "hm-root.nix"
      "iso.nix"
      "kmonad.nix"
      "qemu.nix"
    ];
    recursive = true;
  } ./.;
}
