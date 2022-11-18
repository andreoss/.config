{ config, pkgs, lib, stdenv, ... }: {
  home.stateVersion = "22.05";
  home.packages = with pkgs; [ nvi pciutils usbutils ];
  xsession = {
    enable = true;
    scriptPath = ".xsession";
    windowManager.command = ''
       ${pkgs.icewm}/bin/icewm-session &
       ${pkgs.feh}/bin/feh --no-fehbg --bg-center ${../wp/1.jpeg} &
       while :
       do
          sleep 1m
       done
      wait
    '';
  };
}
