{ lib, config, pkgs, utils, ... }:
let
  cfg = config.wg-container;
  containers = builtins.map
    ({ name, ... }@options: ({ interface = "wg-${name}"; } // options))
    (lib.mapAttrsToList
      (name: options: options // (if options.name == null then { inherit name; } else { }))
      cfg.containers);
  enabledContainers = lib.filter (options: options.enable) containers;
  mapContainers = f: builtins.map f enabledContainers;
  mapContainersToAttrs = f: builtins.listToAttrs (mapContainers f);
in
{
  options = {
    wg-container = {
      enable = lib.mkEnableOption ''
        Containers with forced wireguard internet access
      '';
      containers = lib.mkOption {
        type = lib.types.attrsOf
          (lib.types.submodule ({
            options = {
              enable = lib.mkEnableOption ''
                Enable this container
              '';
              name = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = ''
                  The name of this container
                '';
              };
              privateKeyFile = lib.mkOption {
                type = lib.types.str;
                description = ''
                  Location of the private key file.
                '';
              };
              wireguardPeerConfig = lib.mkOption {
                default = { };
                type = lib.types.attrsOf lib.types.str;
                description = lib.mdDoc ''
                  Each attribute in this set specifies an option in the
                  `[WireGuardPeer]` section of the unit.  See
                  {manpage}`systemd.network(5)` for details.
                '';
              };
              wireguardIPs = lib.mkOption {
                default = [ ];
                type = lib.types.listOf lib.types.str;
                description = lib.mdDoc ''
                  The IPs associated with the wireguard interface.
                '';
              };
              dns = lib.mkOption {
                default = [ ];
                type = lib.types.listOf lib.types.str;
                description = lib.mdDoc ''
                  List of DNS servers in this container.
                '';
              };
              config = lib.mkOption {
                type = lib.types.deferredModule;
                description = ''
                  The NixOS configuration of this container.
                '';
              };
            };
          }));
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.network = {
      enable = true;
      wait-online = {
        anyInterface = true;
        ignoredInterfaces = builtins.map ({ interface, ... }: interface) enabledContainers;
      };

      netdevs = mapContainersToAttrs
        ({ interface, privateKeyFile, wireguardPeerConfig, ... }:
          lib.nameValuePair "10-${interface}" {
            netdevConfig = {
              Kind = "wireguard";
              Name = interface;
              MTUBytes = "1400";
            };
            wireguardConfig = {
              PrivateKeyFile = privateKeyFile;
            };
            wireguardPeers = [
              {
                wireguardPeerConfig = wireguardPeerConfig // {
                  AllowedIPs = "0.0.0.0/0,::/0";
                };
              }
            ];
          });

      networks = mapContainersToAttrs
        ({ interface, dns, wireguardIPs, ... }:
          lib.nameValuePair "40-${interface}" {
            matchConfig.Name = interface;
            inherit dns;
            address = wireguardIPs;
          });
    };

    systemd.services = mapContainersToAttrs
      ({ interface, name, ... }:
        let
          requiredUnits = [
            "sys-subsystem-net-devices-${utils.escapeSystemdPath interface}.device"
            "systemd-networkd-wait-online.service"
          ];
        in
        lib.nameValuePair "container@${utils.escapeSystemdPath name}" {
          requires = requiredUnits;
          wants = requiredUnits;
        });

    containers = mapContainersToAttrs ({ name, interface, config, dns, wireguardIPs, ... }:
      lib.nameValuePair name {
        privateNetwork = true;
        interfaces = [ interface ];
        config = { lib, pkgs, ... }: {
          imports = [ config ];

          networking.useHostResolvConf = false;
          systemd.network = {
            enable = true;
            networks."40-${interface}" = {
              matchConfig.Name = interface;
              inherit dns;
              address = wireguardIPs;
              gateway = [ "0.0.0.0" "::" ];
            };
          };
        };
      });
  };
}
