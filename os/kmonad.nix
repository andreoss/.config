{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.kmonad;
in
with lib;
{
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
    devices = mkOption {
      type = types.listOf types.string;
      default = [ ];
      example = [ "/dev/input/by-id/xxx-event-kbd" ];
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

  config =
    let
      merge = builtins.foldl' (x: y: x // y) { };
      mkKmonadService = d: {
        "kmonad-${strings.sanitizeDerivationName d}" = {
          enable = true;
          description = "KMonad for ${d}";
          restartTriggers = [ d ];
          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            RestartSec = "1s";
            ExecStart =
              let
                c = (
                  builtins.toFile "kbd" (
                    builtins.replaceStrings [ cfg.placeholder ] [ d ] (builtins.readFile cfg.configfile)
                  )
                );
              in
              pkgs.writeShellScript "kmonad.sh" ''
                while [ ! -e ${d} ]
                do
                    sleep 1
                done
                ${cfg.package}/bin/kmonad ${c}
              '';
          };
          wantedBy = [ "graphical.target" ];
        };
      };
    in
    {
      users.groups.uinput = { };

      services.udev.extraRules = mkIf cfg.enable ''
        # KMonad user access to /dev/uinput
        KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
      '';

      systemd.services = mkIf cfg.enable (merge (map (d: mkKmonadService d) cfg.devices));
    };
}
