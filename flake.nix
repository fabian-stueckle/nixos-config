{
  description = "A very basic flake";

  inputs = {
    # nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  };

  outputs = { nixpkgs, ... }: 
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix

        # ({ pkgs, config, ... }: {
        #   imports = [ ];

        #   # ROCm System Packages
        #   environment.systemPackages = with pkgs; [
        #     rocm.rocm-libs
        #     rocm.hip
        #     rocm.rocm-smi
        #     rocm.rocm-opencl-runtime
        #     python313Full
        #     python313Packages.virtualenv
        #   ];

        #   # # Optional: extraPackages for mesa / opencl
        #   # hardware.opengl.extraPackages = with pkgs; [
        #   #   rocm.rocm-opencl-runtime
        #   # ];

        #   # Grafikkarte (Radeon RX 9070)
        #   services.xserver.videoDrivers = [ "amdgpu" ];

        # })
      ];
    };
  };
}
