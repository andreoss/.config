{
  specialArgs,
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config;
  host = "192.168.99.1";
  user = cfg.primaryUser.name;
in
{
  containers.gateway = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = host;
    localAddress = "192.168.99.3";
    config =
      { config, pkgs, ... }:
      {
        system.stateVersion = cfg.stateVersion;
        services.openssh.enable = true;
        services.xserver.enable = true;
        services.openssh.settings.X11Forwarding = false;
        systemd.tmpfiles.rules = [
          "d /nix/var/nix/profiles/per-user/${user} - ${user} - - -"
          "d /nix/var/nix/gcroots/per-user/${user} - ${user} - - -"
        ];
        users.users."${user}" = {
          uid = cfg.primaryUser.uid;
          isNormalUser = true;
          createHome = true;
          openssh.authorizedKeys.keys = cfg.primaryUser.authorizedKeys;
        };
        environment = {
          defaultPackages = with pkgs; [ ];
          systemPackages = with pkgs; [
            xpra
            cwm
            tor-browser
            pulseaudio
          ];
        };
      };
  };
  containers.workstation = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = host;
    localAddress = "192.168.99.2";
    config =
      { config, pkgs, ... }:
      {
        system.stateVersion = cfg.stateVersion;
        services.openssh.enable = true;
        programs.firejail = {
          enable = true;
          wrappedBinaries = { };
        };
        security.wrappers = {
          firejail.source = "${pkgs.firejail.out}/bin/firejail";
        };
        networking = {
          dns-crypt.enable = true;
        };
        services.pipewire = {
          enable = true;
          systemWide = true;
        };
        environment = {
          defaultPackages = with pkgs; [ ];
          systemPackages = with pkgs; [
            pulsemixer
            pulseaudioFull
            pavucontrol
            python3Packages.zeroconf
          ];
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
        imports = [
          specialArgs.inputs.home-manager.nixosModule
          specialArgs.inputs.dnscrypt-module.nixosModules.default
        ];
        users.users."${user}" = {
          uid = cfg.primaryUser.uid;
          isNormalUser = true;
          createHome = true;
          openssh.authorizedKeys.keys = cfg.primaryUser.authorizedKeys;
          home = cfg.primaryUser.home;
        };
        home-manager.users."${user}" = {
          home.stateVersion = cfg.stateVersion;
          imports = [
            ../default.nix
            ../secrets
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
              UnsetEnvironment = "TERM";
              ExecStart = "${pkgs.bash}/bin/bash --login -c 'export DISPLAY=:0; xpra shadow; exec /user/.xsession'";
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
              UnsetEnvironment = "TERM";
              ExecStart = "${pkgs.xorg.xorgserver}/bin/Xvfb :0 -screen 0 1900x1200x24";
              Restart = "always";
              RestartSec = "3";
              Type = "idle";
            };
          };
        };
      };
  };
}
