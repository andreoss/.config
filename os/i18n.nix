{ pkgs, ... }: {
  services.xserver.layout = "us,ru";
  services.xserver.xkbOptions = "ctrl:nocaps,grp:shifts_toggle,compose:ralt";
  i18n = {
    supportedLocales = [
      "en_GB.UTF-8/UTF-8"
      "es_ES.UTF-8/UTF-8"
      "pt_PT.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
    defaultLocale = "ru_RU.utf8";
    extraLocaleSettings = { LC_MESSAGES = "en_GB.utf8"; };
  };
  location = {
    provider = "manual";
    latitude = -28.0;
    longitude = -57.0;
  };
  environment = {
    wordlist = {
      enable = true;
      lists = { WORDLIST = [ "${pkgs.scowl}/share/dict/wbritish.txt" ]; };
    };
  };
}
