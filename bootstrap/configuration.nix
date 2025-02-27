{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
  ];
  boot.loader.grub = {
    efiSupport = true;
    devices = [ "/dev/sda" ];
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  networking.hostId = "13ed26b9";
  networking.hostName = "vm-setup";

  nix.settings.substituters = [
    "https://nix-community.cachix.org"
    "https://cache.nixos.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-cache.aermel.net:nIgjKq1imiwaDAF0YtMsJ84AYVQPODXaXN4P2f3rI58="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.vim
    pkgs.python3
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCw5+kIGKen92h5FHc9gEtEc8sdtpDlAB9nAvcdRw2o emil.breiner99@gmail.com"
  ];

  system.stateVersion = "24.11";
}
