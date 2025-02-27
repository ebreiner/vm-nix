{
  description =  "VictoriaMetrics server component for platform";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }: {
    modules.victoria_metrics = { config, lib, ... }: let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      services = {
        nginx = {
          virtualHosts.victoria_metrics = {
            locations = {
              "/" = {
                proxyPass = "http://127.0.0.1:8428/";
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
              ExecStart = "${pkgs.victoriametrics}/bin/victoria-metrics -storageDataPath=/var/lib/victoria-metrics -retentionPeriod=31 "; #-httpAuth.username=admin -httpAuth.password={{ lookup('ansible.builtin.env', 'LOGS_CONFIG_PASSWORD') }}";
              DynamicUser = true;
              StateDirectory = "victoria-metrics";
              StateDirectoryMode = 0700;
            };
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 80 ];
      networking.firewall.allowedUDPPorts = [ ];
    };
  };
}