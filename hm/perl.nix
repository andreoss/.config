{ config, pkgs, lib, stdenv, self, ... }: {
  config = {
    home.packages = with pkgs.perl536Packages; lib.optionals(config.ao.primaryUser.languages.perl) [
      ModernPerl
      Moose
      Appcpanminus
      PerlCritic
      PerlTidy
      PodTidy
      HTMLTidy
      BUtils
      Appperlbrew
    ] ++ (with pkgs; [
      perl536
      rakudo
      zef
    ]);
  };
}
