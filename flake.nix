{
  description = "A very basic flake";

  inputs = {
    # nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  };

  # outputs = { nixpkgs, nixpkgs-unstable, ... } @ inputs: 
  outputs = { nixpkgs, ... }: 
  # let 
  #   pkgs = import nixpkgs {
  #     system = "x86_64-linux";
  #     overlays = [
  #       (final: prev: {

  #       })
  #     ];
  #   };
  # in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
