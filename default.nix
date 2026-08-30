{ lib, ... }:
with lib;
{
  options.hostId = mkOption { type = types.str; };
  options.primaryUser = {
    # Non-secret defaults for the host identity, so the tree evaluates standalone.
    name = mkOption { type = types.str; default = "user"; };
    handle = mkOption { type = types.str; default = "user"; };
    email = mkOption { type = types.str; default = "user@example.com"; };
    gpgKey = mkOption { type = types.str; default = ""; };
    authorizedKeys = mkOption {
      type = types.listOf (types.str);
      default = [ ];
    };
    key = mkOption { type = types.str; default = ""; };
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
  options.backgroundImage = mkOption {
    type = types.path;
    default = ./wp/1.jpeg;
  };
  options.minimalInstallation = mkOption {
    type = types.bool;
    default = false;
  };
   options.autoLogin = mkOption { type = types.bool; default = false; };
  options.autoLock = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    time = mkOption {
      type = types.int;
      default = 10;
    };
  };
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

  options.dpi = mkOption {
    type = types.int;
    default = 100;
  };
  options.locale = mkOption {
    type = types.str;
    default = "ru_RU.utf8";
  };
  options.kernel = mkOption {
    type = types.str;
    default = "linuxPackages";
  };
  options.sslProxy = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    crt = mkOption { type = types.str; };
    pem = mkOption { type = types.str; };
  };
  options.preferedLocalIp = mkOption {
    type = types.str;
    default = "192.168.0.100";
  };
  options.extraHosts = mkOption {
    type = types.str;
    default = "";
  };
  options.dhcpcdExtraConfig = mkOption {
    type = types.functionTo (types.str);
    default = ip: "";
  };
}
