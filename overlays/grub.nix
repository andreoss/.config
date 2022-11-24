self: super: {
  grub2 = (super.pkgs.grub2.override { }).overrideAttrs (attrs: {
    patches = [ ./01-quite.patch ./02-no-uuid.patch ] ++ attrs.patches;
  });
}
