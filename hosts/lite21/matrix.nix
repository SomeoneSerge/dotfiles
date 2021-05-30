{ config, pkgs, lib, ... }:

let
  hostAddress = "192.168.100.10";
  localAddress = "192.168.100.11";
  hostName = "matrix";
  domain = "someonex.net";
  fqdn = let
    join = hostName: domain:
      hostName + lib.optionalString (domain != null) ".${domain}";
  in join hostName domain;
in {
  services.nginx.virtualHosts = {
    "${domain}" = {
      enableACME = true;
      forceSSL = true;

      locations."= /.well-known/matrix/server".extraConfig =
        let server = { "m.server" = "${fqdn}:443"; };
        in ''
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON server}';
        '';
      locations."= /.well-known/matrix/client".extraConfig = let
        client = {
          "m.homeserver" = { "base_url" = "https://${fqdn}"; };
          "m.identity_server" = { "base_url" = "https://vector.im"; };
        };
      in ''
        add_header Content-Type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '${builtins.toJSON client}';
      '';
    };

    # Reverse proxy for Matrix client-server and server-server communication
    ${fqdn} = {
      enableACME = true;
      forceSSL = true;

      locations."/".extraConfig = ''
        return 404;
      '';

      # forward all Matrix API calls to the synapse Matrix homeserver
      locations."/_matrix" = {
        proxyPass = "http://${localAddress}:8008"; # without a trailing /
      };
    };
  };
  containers.matrix = {
    autoStart = true;
    privateNetwork = true;
    inherit hostAddress localAddress;
    config = ({ config, pkgs, lib, ... }: {
      networking = {
        inherit domain hostName;
        firewall.allowedTCPPorts = [ 80 443 8008 ];
      };

      services.postgresql.enable = true;
      services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
        CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
        CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
          TEMPLATE template0
          LC_COLLATE = "C"
          LC_CTYPE = "C";
      '';

      services.matrix-synapse = {
        enable = true;
	# enable_registration = true;
        server_name = config.networking.domain;
        listeners = [{
          port = 8008;
          bind_address = localAddress;
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [{
            names = [ "client" "federation" ];
            compress = false;
          }];
        }];
      };
    });
  };
}
