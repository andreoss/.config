{
  config,
  lib,
  ...
}:
let
  x = false;
in
{
  config = lib.mkIf (builtins.elem "email" config.features) {
    programs = lib.attrsets.optionalAttrs (x) {
      mbsync.enable = x;
      msmtp.enable = x;
    };
    services = lib.attrsets.optionalAttrs (x) { mbsync.enable = x; };
  };
}
