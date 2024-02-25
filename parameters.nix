{ lib, ... }:
with lib; {
  options.xxx = mkOption { type = types.attrs; };
  options.minimalInstallation = mkOption {
    type = types.bool;
    default = false;
  };
  options.autoLogin = mkOption {
    type = types.bool;
    default = true;
  };
}
