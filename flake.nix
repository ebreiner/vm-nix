{
  description = "Nixos configuration of platform brain node";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    victoriaMetrics = { url = "./flakes/victoria_metrics"; };
  };

  outputs = {
    self,
    nixpkgs,
    victoriaMetrics,
    ...
  }@inputs: {
    nixosConfigurations = {

      vm-demo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          victoriaMetrics.outputs.modules.victoria_metrics
        ];
      };

      net-aermel-observability = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix
          ./host-configs/net-aermel-observability.nix
          victoriaMetrics.outputs.modules.victoria_metrics
        ];
      };
    };
  };
}
