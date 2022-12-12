final: prev: {
  grub2 = (prev.pkgs.grub2.override { }).overrideAttrs (oldattrs: rec {
    patches = [ ./01-quite.patch ./02-no-uuid.patch ] ++ oldattrs.patches;
  });
}
