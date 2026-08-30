{
  hostname = "livecd";
  config = {
    primaryUser = {
      name = "user";
      handle = "user";
      email = "user@example.com";
      gpgKey = "";
      key = "";
    };
    autoLogin = false;
  };
  overlays = [ ];
  modules = [
    ../os/iso.nix
  ];
}
