{ pkgs, config, lib, ... }:

let cfg = config.services.kmonad;
in with lib; {
  options.services.kmonad = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, run kmonad after boot.
      '';
    };
    placeholder = mkOption {
      type = types.string;
      default = "DEVICE";
      description = ''
        Placeholder for device.
      '';
    };
    device = mkOption {
      type = types.string;
      default = "";
      example = "/dev/input/by-id/xxx-event-kbd";
      description = ''
        Actual device.
      '';
    };
    configfile = mkOption {
      type = types.path;
      default = "";
      example = "my-config.kbd";
      description = ''
        The config file for kmonad.
      '';
    };
    package = mkOption {
      type = types.package;
      description = ''
        The kmonad package.
      '';
    };
  };

  config = {
    environment.systemPackages = [ cfg.package ];

    users.groups.uinput = { };

    services.udev.extraRules = mkIf cfg.enable ''
      # KMonad user access to /dev/uinput
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';

    systemd.services.kmonad = mkIf cfg.enable {
      enable = true;
      description = "KMonad";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/kmonad " + (builtins.toFile "kbd"
          (builtins.replaceStrings [ cfg.placeholder ] [ cfg.device ]
            (builtins.readFile cfg.configfile)));
      };
      wantedBy = [ "graphical.target" ];
    };
  };
}
