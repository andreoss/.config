{ lib, ... }:
with lib; {
  options.ao = mkOption { type = types.attrs; };
  options.isLivecd = mkOption {
    type = types.bool;
    default = false;
  };
  options.mini = mkOption {
    type = types.bool;
    default = false;
  };
  options.kbdDevice = mkOption {
    type = types.str;
    default = "/dev/input/kbd";
  };
  config.ao = {
    stateVersion = "23.05";
    fileSystems = { btrfsOptions = [ "compress=zstd" ]; };
    pipewireReplacesPulseaudio = true;
    isLivecd = false;
    primaryUser = {
      name = "a";
      uid = 1337;
      passwd =
        "$6$FpbouABGBk53rccL$9.YA5q3qJOo0SHjJlZ.yjPjg.xczCkIHqJtcaeGbkt9N5//M60s8VzoTWhNy1FIPOQdT9aKGSgCv0GShLzDxo/";

      handle = "andreoss";
      email = "andreoss@sdf.org";
      key = "57CC46231DA832A8";
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCaGxzjPFUqy3uhXw3RgOGgMrvbJBJCpN5/ckx2D92+rsMxH9FdeZWqtXSKe3Ra1lzfyrn7NUSab2ly8/aSpgtG0lUxkKWBPuaR4OBEqpq4ODlafjuLooyXp7OLZWhXdTutqSMjAi8H+rtUryGpQhFsYV171nVUVOf/Sychmir/GIquZI6du1C19P9tFD+BaKqBzOty3z3lr4L/3MOVcWjoOFL2SPcdCIx0rPl6H+MqxjTc1h5CIos2h5feDjLJnfG9+xt2eGe8xu0aVNCKzwEqO47hYN6uLO9Y7ScnFj5/TDD+K7FJkyH9Ly0hZtM8YWhfBVVzrKM7zFjA4D52ffjeGkt0z0zWXWxNLWNLvM2xVIlYMcWwdwNdzf4OYGljCjLXh8Za7v9ZszURZ3JkRwN/4ZAlqgXLK4Vk2NMS3RhvY/b7Vi1TGhw8NMfX+6LReLG4NOoX2Uyiq5Dh2s2dFFOYsu+S1FvYyulih3POWePn2lF0Gj3lheQWllc9J38chdM= a"
      ];
      home = "/user";
      autoLogin = true;
      emacsFromNix = true;
      graphics = true;
      mail = true;
      office = false;
    };
  };
}
