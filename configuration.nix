{
  lib,
  pkgs,
  ...
}:
{
  imports = [
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = false;
  zramSwap.enable = true;

  nix.settings.substituters = [
    "https://nix-community.cachix.org"
    "https://cache.nixos.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  boot.zfs.extraPools = [ "zroot" ];
  boot.zfs.forceImportAll = true;
  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    devices = [ "nodev"];
  };

  # Mount in initial ram disk. All other zfs are automatically mounted there, just tmp not. If not, the tmp.mount
  # will start to early in the boot. And to add a dependency we have to hook into the systemd-generator for the unit.
  fileSystems."/tmp".neededForBoot = true;

  networking = {
    hostName = "vm-demo";
    hostId = "13ed26b9";
    domain = "example.com";
    nameservers = [ "8.8.8.8"];
    defaultGateway = "172.31.1.1";
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="138.199.162.83"; prefixLength=32; }
        ];
        ipv4.routes = [ { address = "172.31.1.1"; prefixLength = 32; } ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    git
    python3
    vim
  ];

  services.nginx = {
    enable = true;
    enableReload = true;
  };
  systemd.services = {
    nginx = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.openssh.enable = true;
  # Directory and group for role-id and secret-id for approle auto auth for vault agents. With a single ica everthing
  # else would be not worth until more ica. The user and group are shared between service. So preparing them upfront
  # enables just adding the user of a service in the respective module to the shared group and it removes headeche and
  # the need for bootstrapping the user after initial node provisioning and before running the first real rebuild.
  users = {
    users = {
      root.openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCw5+kIGKen92h5FHc9gEtEc8sdtpDlAB9nAvcdRw2o emil.breiner99@gmail.com''
      ];
    };
  };
}