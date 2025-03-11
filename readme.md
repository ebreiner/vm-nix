# Readme

## Setup generic nix
- bootstrap directory can be used with nixos-anywhere to install nixos via ssh onto a target linux machine (target gets
utterly destroyed in the process so nixos can rise from the ashes)
- only root access via ssh is needed and the provided set of configuration inside the bootstrap directory
- if a nix installation is provided on the controlling host machine:
```
nix run github:nix-community/nixos-anywhere -- \
 --generate-hardware-config nixos-generate-config ./hardware-configuration.nix \
  --flake .#hetzner-cloud \
  root@foo.aermel.net
```
