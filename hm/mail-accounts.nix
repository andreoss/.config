{
  config,
  pkgs,
  lib,
  ...
}:
let
  x = false;
in
{
  config = lib.mkIf (builtins.elem "email" config.features) {
    accounts = lib.attrsets.optionalAttrs (x) {
      email = {
        maildirBasePath = "${config.home.homeDirectory}/Maildir";
      };
      email.accounts = { };
    };
    home.packages = with pkgs; [ rss2email ];
  };
}
