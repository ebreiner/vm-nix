{
  config = {
    networking = {
      hostName = "observability";
      domain = "aermel.net";
      hostId = "abcd1234";

      interfaces = {
        eth0 = {
          ipv4.addresses = [
            { address="138.199.162.83"; prefixLength=32; }
          ];
          ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
        };
      };
    };

    composite-services.victoria-metrics = {
      enable = true;
      useLetsEncryptTLS = true;
      acmeEmail = "emil.breiner99@gmail.com";
      fqdn = "metrics.aermel.net";
      basicAuthEnable = true;
      basicAuthContent = ''
        emil:$apr1$gz9hWvdo$Sx6SAKLRz.GQqSFspnJhC.
      '';
    };

  };
}
