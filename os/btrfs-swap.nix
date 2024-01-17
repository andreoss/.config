{ lib, pkgs, modulesPath, ... }: {
  config = {
    systemd = {
      services = {
        create-swapfile = let
          mem = pkgs.runCommand "meminfo.nix" { } ''
            ${pkgs.gawk.out}/bin/awk -F'[: ]+' 'BEGIN {print "{\n";} /Mem/{ printf "\t\"%s\" = %d;\n", $1, $2; }; END {print "}";}' /proc/meminfo > "$out"'';
          memInfo = import "${mem.out}";
          swapFile = "/nix/var/swap";
        in {
          serviceConfig.Type = "oneshot";
          wantedBy = [ "nix-var-swap.swap" ];
          script = ''
            if [ -e ${swapFile} ]
            then
              ${pkgs.util-linux}/bin/swapoff ${swapFile}
              ${pkgs.coreutils}/bin/rm --force ${swapFile}
            fi
            ${pkgs.btrfs-progs}/bin/btrfs filesystem mkswapfile --size ${
              builtins.toString memInfo.MemTotal
            }K ${swapFile}
            ${pkgs.util-linux}/bin/swapon ${swapFile} 
          '';
        };
      };
    };
    swapDevices = [{ device = "/nix/var/tmp/swap"; }];
  };
}
