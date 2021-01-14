{ options, config, lib, pkgs, ... }:

with lib;
with lib.my;
let cfg = config.modules.services.matrix;
    domain = config.networking.domain;
in {
  options.modules.services.matrix = { 
    enable = mkBoolOpt false;
    registration = mkBoolOpt false;
    element = mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    modules.services.acme.enable = true;
    modules.services.nginx.enable = true;

    networking.firewall.allowedTCPPorts = [
      8448 # Matrix federation
    ];

    services = mkMerge [
      (mkIf cfg.element {
        nginx.virtualHosts."element.${domain}" = {
          enableACME = true;
          forceSSL = true;

          root = pkgs.element-web.override {
            conf = {
              default_server_config."m.homeserver" = {
                "base_url" = "https://matrix.${domain}";
                "server_name" = "${domain}";
              };
            };
          };
        };
      })
      {
        matrix-synapse = {
          enable = true;
          server_name = domain;
          enable_registration = cfg.registration;
          registration_shared_secret = secrets.matrix.password;

          public_baseurl = "https://matrix.${domain}";
          tls_certificate_path = "/var/lib/acme/matrix.isnt.online/fullchain.pem";
          tls_private_key_path = "/var/lib/acme/matrix.isnt.online/key.pem";

          database_type = "psycopg2";
          database_args = { database = "matrix-synapse"; };

          listeners = [
            { # federation
              bind_address = "";
              port = 8448;
              resources = [
                {
                  compress = true;
                  names = [ "client" "webclient" ];
                }
                {
                  compress = false;
                  names = [ "federation" ];
                }
              ];

              tls = true;
              type = "http";
              x_forwarded = false;
            }
            { # client
              bind_address = "127.0.0.1";
              port = 8008;
              resources = [{
                compress = true;
                names = [ "client" "webclient" ];
              }];
              tls = false;
              type = "http";
              x_forwarded = true;
            }
          ];

          extraConfig = ''
            max_upload_size: "100M"
          '';
        };

        nginx = {
          virtualHosts = {
            "matrix.${domain}" = {
              forceSSL = true;
              enableACME = true;
              locations."/" = { proxyPass = "http://127.0.0.1:8008"; };
            };
          };
        };

        postgresql = {
          enable = true;
          initialScript = pkgs.writeText "synapse-init.sql" ''
            CREATE USER "matrix-synapse";

            CREATE DATABASE "matrix-synapse"
                ENCODING 'UTF8'
                LC_COLLATE='C'
                LC_CTYPE='C'
                template=template0
                OWNER "matrix-synapse";
          '';
        };
      }
    ];
  };
}