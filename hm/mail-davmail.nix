let
  address = "";
  domain = builtins.elemAt (builtins.split "@" address) 2;
  name = "";
in {
  "${address}" = {
    primary = false;
    address = "${address}";
    realName = "${name}";
    userName = "${address}";
    passwordCommand = "pass show w/${domain}/${address}";
    imap = {
      host = "127.0.0.1";
      port = 1143;
      tls = { enable = false; };
    };
    smtp = {
      host = "localhost";
      port = 1025;
      tls = {
        enable = true;
        useStartTls = true;
      };
    };
    mbsync = {
      enable = true;
      create = "maildir";
      extraConfig.account = {
        Timeout = 0;
        AuthMechs = "LOGIN";
      };
    };
    msmtp = {
      enable = true;
      extraConfig = {
        passwordeval = "pass show w/${domain}/${address}";
        user = "${address}";
      };
    };
    notmuch = { enable = true; };
  };
}
