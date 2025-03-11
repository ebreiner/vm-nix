{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
  ];

  config = {

    system.stateVersion = "24.11";

    nix = {
      settings.experimental-features = [ "nix-command" "flakes" ];
      settings.substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      settings.trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    nixpkgs.config.allowUnfree = true;
    zramSwap.enable = true;

    boot = {
      zfs.extraPools = [ "zroot" ];
      zfs.forceImportAll = true;
      loader.grub = {
        enable = true;
        zfsSupport = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        devices = [ "nodev"];
      };
      tmp.cleanOnBoot = true;
      tmp.useTmpfs = false;
    };

    networking = {
        nameservers = [ "8.8.8.8"];
        defaultGateway = "172.31.1.1";
        dhcpcd.enable = false;
        usePredictableInterfaceNames = lib.mkForce false;
        firewall.allowedTCPPorts = [ 80 443 ];
      };

    services = {
      nginx = {
        enable = true;
        enableReload = true;
      };
      openssh = {
        enable = true;
      };
    };

    systemd.services = {
      nginx = {
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
      };
    };

    environment.systemPackages = with pkgs; [
       vim
     ];

    # Mount in initial ram disk. All other zfs are automatically mounted there, just tmp not. If not, the tmp.mount
    # will start to early in the boot. And to add a dependency we have to hook into the systemd-generator for the unit.
    fileSystems = {
      "/tmp" = {
        neededForBoot = true;
        fsType = "zfs";
        device = "zroot/local/tmp";
      };
      "/" = {
        fsType = "zfs";
        device = "zroot/local/root";
      };
      "/nix" = {
        fsType = "zfs";
        device = "zroot/local/nix";
      };
      "/var" = {
        fsType = "zfs";
        device = "zroot/local/var";
      };
    };

    users = {
      users = {
        root.openssh.authorizedKeys.keys = [
          ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCw5+kIGKen92h5FHc9gEtEc8sdtpDlAB9nAvcdRw2o emil.breiner99@gmail.com''
          ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBB2NZZtLTwJZS69fyWvXCHcgE0CUv4lLfBN1M61gtza emil@barney''
        ];
      };
    };

  };
}
