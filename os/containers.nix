{ specialArgs, inputs, lib, pkgs, config, ... }:
let
  cfg = config.ao;
  host = "192.168.99.1";
  user = cfg.primaryUser.name;
in {
  containers.workstation = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = host;
    localAddress = "192.168.99.2";
    config = { config, pkgs, ... }: {
      system.stateVersion = cfg.stateVersion;
      services.openssh.enable = true;
      programs.firejail = {
        enable = true;
        wrappedBinaries = { };
      };
      security.wrappers = {
        firejail.source = "${pkgs.firejail.out}/bin/firejail";
      };
      environment = {
        defaultPackages = with pkgs; [ ];
        systemPackages = with pkgs; [
          pulsemixer
          pulseaudioFull
          pavucontrol
          python3Packages.avahi
          python3Packages.zeroconf
        ];
        variables.PULSE_SERVER = "tcp:${host}:4713";
        etc = {
          inputrc.source = ../inputrc;
          issue.source = lib.mkOverride 0 (pkgs.writeText "issue" "");
          "resolv.conf".text = "nameserver ${host}";
        };
      };
      systemd.tmpfiles.rules = [
        "d /nix/var/nix/profiles/per-user/${user} - ${user} - - -"
        "d /nix/var/nix/gcroots/per-user/${user} - ${user} - - -"
      ];
      home-manager.extraSpecialArgs = specialArgs;
      imports = [ specialArgs.inputs.home-manager.nixosModule ];
      users.users."${user}" = {
        uid = cfg.primaryUser.uid;
        isNormalUser = true;
        createHome = true;
        openssh.authorizedKeys.keys = cfg.primaryUser.keys;
        home = cfg.primaryUser.home;
      };
      home-manager.users."${user}" = {
        home.stateVersion = cfg.stateVersion;
        imports = [
          ../config.nix
          ../hm/base.nix
          ../hm/xsession-base.nix
          ../hm/sh.nix
          ../hm/term.nix
          ../hm/work.nix
        ];
        xsession = {
          enable = true;
          scriptPath = ".xsession";
          windowManager.command = ''
            exec ${pkgs.ratpoison}/bin/ratpoison
          '';
        };
      };
      systemd.services = {
        xsession = {
          enable = true;
          description = "xsession";
          wantedBy = [ "multi-user.target" ];
          after = [ "xvfb.service" ];
          serviceConfig = {
            User = user;
            WorkingDirectory = "~";
            PAMName = "login";
            UtmpMode = "user";
            UnsetEnvirnment = "TERM";
            ExecStart =
              "${pkgs.bash}/bin/bash --login -c 'export DISPLAY=:0; xpra shadow; exec /user/.xsession'";
            Restart = "always";
            RestartSec = "3";
            Type = "idle";
          };
        };
        xvfb = {
          enable = true;
          description = "xvfb";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = user;
            WorkingDirectory = "~";
            PAMName = "login";
            UtmpIdentifier = "tty1";
            UtmpMode = "user";
            UnsetEnvirnment = "TERM";
            ExecStart =
              "${pkgs.xorg.xorgserver}/bin/Xvfb :0 -screen 0 1600x1000x24";
            Restart = "always";
            RestartSec = "3";
            Type = "idle";
          };
        };
      };
    };
  };
}
