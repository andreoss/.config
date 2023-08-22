{ pkgs, ... }: {
  services.xserver.layout = "us,ru";
  services.xserver.xkbOptions = "ctrl:nocaps,grp:shifts_toggle,compose:ralt";
  i18n = {
    supportedLocales = [ "en_GB.utf8" "es_ES.utf8" "pt_PT.utf8" "ru_RU.utf8" ];
    defaultLocale = "ru_RU.utf8";
    extraLocaleSettings = { LC_MESSAGES = "en_GB.utf8"; };
  };
  time.timeZone = "America/New_York";
  location.provider = "manual";
  location.latitude = -28.0;
  location.longitude = -57.0;
  environment = {
    wordlist = {
      enable = true;
      lists = { WORDLIST = [ "${pkgs.scowl}/share/dict/wbritish.txt" ]; };
    };
  };
}
