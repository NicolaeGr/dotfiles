{
  description = "My First Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };
    in
    {
      nixosConfigurations = {
        # odin = nixpkgs.lib.nixosSystem {
        #   specialArgs = {
        #     hostName = "odin";
        #     inherit inputs system;
        #   };

        #   modules = [
        #     home-manager.nixosModules.home-manager

        #     ./modules/core

        #     ./hosts/odin
        #   ];

        #   system.stateVersion = "23.11";
        # };

        zion = nixpkgs.lib.nixosSystem {
          specialArgs = {
            hostName = "zion";
            inherit inputs system;
          };

          modules = [
            ./modules/core

            home-manager.nixosModules.home-manager

            ./modules/hardware
            ./modules/hardware/nvidia
            ./modules/hyprland


            ./hosts/zion
          ];
        };
      };
    };
}

