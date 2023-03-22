{ config, pkgs, lib, stdenv, self, ... }:
let cfg = config.home.development.perl;
in {
  options = {
    home.development.perl = with lib; {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      version = mkOption {
        type = types.str;
        default = "536";
      };
    };
  };
  config = {
    home.packages = lib.optionals cfg.enable
      (with pkgs."perl${cfg.version}Packages";
        [
          AnyEvent
          Appcpanminus
          Appperlbrew
          BUtils
          Coro
          DataDump
          DBDSQLite
          DBI
          DBIxClass
          FileUtil
          HTMLTidy
          JSON
          ModernPerl
          Mojolicious
          Moose
          NetSSLeay
          PerlCritic
          PerlTidy
          PodTidy
          TextCSV_XS
          Tk
          TryTiny
          YAML
        ] ++ [ pkgs."perl${cfg.version}" pkgs.rakudo pkgs.zef ]);
  };
}
