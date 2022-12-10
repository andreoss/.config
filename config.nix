{ lib, pkgs, config, ... }:
with lib;
let cfg = config.services.hello;
in {
  options.ao = mkOption { type = types.attrs; };
  # stateVersion = mkOption { default = "22.11" ; type = types.str; };
  # pipewireReplacesPulseaudio = mkOption {type = types.bool;};
  # fileSystems = mkOption {type = types.attrs;};
  # primaryUser = mkOption {type = types.attrs;};
  #   {
  #   name = "a";
  #   home = "/user";
  #   autoLogin = true;
  #   emacsFromNix = true;
  #   graphics = true;
  #   mail = true;
  #   languages = {
  #     java = true;
  #     perl = true;
  #     scala = true;
  #     android = false;
  #   };
  # };
  #};
  config.ao = {
    stateVersion = "22.11";
    fileSystems = { btrfsOptions = [ "compress=zstd" ]; };
    pipewireReplacesPulseaudio = true;
    primaryUser = {
      name = "a";
      home = "/user";
      autoLogin = true;
      emacsFromNix = true;
      graphics = true;
      mail = true;
      languages = {
        java = true;
        perl = true;
        scala = true;
        android = false;
      };
    };
  };
}
