{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
    ./qemu-config.nix
    ./console.nix
    ./../default.nix
    ./boot.nix
    # ./boot-grub.nix
    ./users.nix
    ./i18n.nix
    ./fonts.nix
    { config.primaryUser.name = "a"; }
    {
      users.extraUsers.root.password = lib.mkForce "";
      users.extraUsers.${config.primaryUser.name}.password = lib.mkForce "";
      services.kmscon = {
        enable = true;
        autologinUser = "a";
        fonts = [
          {
            name = "Terminus";
            package = pkgs.terminus_font_ttf;
          }
        ];
        extraOptions = "--font-name=Terminus--font-dpi=${builtins.toString config.dpi} --term xterm-256color  --xkb-options=${config.services.xserver.xkb.options} --xkb-layout=${config.services.xserver.xkb.layout}";
      };
    }
  ];

  system.build.qcow2 = import "${modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    diskSize = 128000;
    format = "qcow2";
    partitionTableType = "hybrid";
  };
}
