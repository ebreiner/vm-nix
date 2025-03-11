{
  description =  "VictoriaMetrics flake batteries-included";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }: {
    modules.victoria_metrics = { config, lib, ... }: let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      cfg = config.composite-services.victoria-metrics;
    in {
      options.composite-services.victoria-metrics = with lib; {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable batteries included victoria-metrics server";
        };

        useLetsEncryptTLS = mkOption {
          type = types.bool;
          default = true;
          description = "Controls if a x509 should be issued via lets encrypt, ";
        };

        acmeEmail = mkOption {
          type = types.str;
          description = "Mail address to be used for issuing the x509";
        };

        fqdn = mkOption {
          type = types.str;
          default = "${toString config.networking.hostName}.${toString config.networking.domain}";
          description = "FQDN used for the x509 and reverse proxy, defaults to the fqdn of the host";
        };

        basicAuthContent = mkOption {
          type = types.str;
          description = "Content of the basic auth passwd file";
        };
      };

      config = {
        security.acme.acceptTerms = cfg.useLetsEncryptTLS;
        security.acme.defaults.email = cfg.acmeEmail;
        services = {
          nginx = {
            virtualHosts.victoria_metrics = {
              serverName = cfg.fqdn;
              enableACME = cfg.useLetsEncryptTLS;
              forceSSL = cfg.useLetsEncryptTLS;
 # TODO: https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/
              locations = {
                "/" = {
                  proxyPass = "http://127.0.0.1:8428/vmui/";
                  basicAuthFile = pkgs.writeText "victoria-metrics-basicauth" cfg.basicAuthContent;
                  extraConfig = ''
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  '';
                };
              };
            };
          };
        };

        systemd = {
          services = {
            victoria-metrics = {
              description = "VictoriaMetrics daemon";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];
              serviceConfig = {
                ExecStart = "${pkgs.victoriametrics}/bin/victoria-metrics -storageDataPath=/var/lib/victoria-metrics -retentionPeriod=31";
                DynamicUser = true;
                StateDirectory = "victoria-metrics";
                StateDirectoryMode = 0700;
              };
            };
          };
        };

        networking.firewall.allowedTCPPorts = [ 80 ];
        networking.firewall.allowedUDPPorts = [ 443 ];

      };

    };
  };
}
