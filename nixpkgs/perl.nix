{ config, pkgs, lib, stdenv, self, ... }: {
  config = lib.attrsets.optionalAttrs (self.config.primaryUser.languages.perl) {
    home.packages = with pkgs.perl536Packages; [
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
