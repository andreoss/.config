{ lib, pkgs, config, ... }:
with lib;
{
  options.ao = mkOption { type = types.attrs; };
  options.isLivecd = mkOption {type = types.bool; default = false ;};
  options.mini = mkOption {type = types.bool; default = false ;};
  options.kbdDevice = mkOption {type = types.str; default = "/dev/input/kbd";};

  config.ao = {
    stateVersion = "22.11";
    fileSystems = { btrfsOptions = [ "compress=zstd" ]; };
    pipewireReplacesPulseaudio = true;
    isLivecd = false;
    primaryUser = {
      name = "a";
      uid = 1337;
      passwd = "$6$FpbouABGBk53rccL$9.YA5q3qJOo0SHjJlZ.yjPjg.xczCkIHqJtcaeGbkt9N5//M60s8VzoTWhNy1FIPOQdT9aKGSgCv0GShLzDxo/";
      handle = "andreoss";
      email = "andreoss@sdf.org";
      key = "2DB39B412CDF97C7";
      home = "/user";
      autoLogin = true;
      emacsFromNix = true;
      graphics = true;
      mail = true;
      media = true;
      office = true;
      languages = {
        java = true;
        perl = true;
        scala = true;
        android = false;
        clojure = true;
        rust = true;
        ruby = true;
        haskell = true;
        lisp = true;
        cxx  = true;
      };
    };
  };
}
