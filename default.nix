{ lib, ... }:
with lib; {
  options.hostId = mkOption { type = types.str; };
  options.primaryUser = {
    name = mkOption { type = types.str; };
    handle = mkOption { type = types.str; };
    email = mkOption { type = types.str; };
    gpgKey = mkOption { type = types.str; };
    authorizedKeys = mkOption {
      type = types.listOf (types.str);
      default = [ ];
    };
    key = mkOption { type = types.str; };
    uid = mkOption {
      type = types.int;
      default = 1337;
    };
    home = mkOption {
      type = types.str;
      default = "/user";
    };

    passwd = mkOption {
      type = types.str;
      default = "*";
    };
  };
  options.minimalInstallation = mkOption {
    type = types.bool;
    default = false;
  };
  options.autoLogin = mkOption { type = types.bool; };
  options.preferPipewire = mkOption {
    type = types.bool;
    default = true;
  };
  options.stateVersion = mkOption {
    type = types.str;
    default = "23.11";
  };
  options.features = mkOption {
    type = types.listOf (types.str);
    default = [ ];
  };

}