{ config, pkgs, lib, stdenv, self, ... }: {
  config = {
    home.packages = with pkgs.perl536Packages; lib.optionals(config.ao.primaryUser.languages.perl) [
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
    ] ++ (with pkgs; [
      perl536
      rakudo
      zef
    ]);
  };
}
