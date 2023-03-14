{ config, lib, pkgs, ... }:

with lib;

let cfg = config.networking.dns-crypt;
in {
  options.networking.dns-crypt = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };
  config = {
    services = {
      unbound = mkIf cfg.enable {
        enable = true;
        resolveLocalQueries = true;
        enableRootTrustAnchor = false;
        settings = {
          server = {
            interface = [ "127.0.0.1" "192.168.99.1" ];
            do-not-query-localhost = "no";
            hide-identity = "yes";
            hide-version = "yes";
            verbosity = 4;
            prefetch = "yes";
            prefetch-key = "yes";
            minimal-responses = "yes";
            access-control = [ "127.0.0.0/8 allow" "192.168.99.0/28 allow" ];
          };
          forward-zone = [{
            name = ".";
            forward-addr = [ "127.0.0.1@5553" ];
          }];
        };
      };
      dnscrypt-proxy2 = mkIf cfg.enable {
        enable = true;
        settings = {
          ipv6_servers = false;
          require_dnssec = true;
          listen_addresses = [ "127.0.0.1:5553" ];
          sources.public-resolvers = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
              "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
            ];
            cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
            minisign_key =
              "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          };
        };
      };
    };
    systemd.services.unbound =
      mkIf cfg.enable { partOf = [ "network.target" ]; };
    systemd.services.dnscrypt-proxy2 = mkIf cfg.enable {
      requires = [ "unbound.service" ];
      partOf = [ "network.target" ];
    };
    networking = mkIf cfg.enable {
      networkmanager = { insertNameservers = [ "127.0.0.1" ]; };
      nameservers = [ "127.0.0.1" ];
      dhcpcd = {
        extraConfig = ''
          duid
          noarp
          static domain_name_servers=127.0.0.1
        '';
      };
    };
    environment = {
      etc = mkIf cfg.enable {
        "resolv.conf" = {
          mode = "0444";
          source = lib.mkOverride 0 (pkgs.writeText "resolv.conf" ''
            nameserver 127.0.0.1
          '');
        };
      };
    };
  };
}
