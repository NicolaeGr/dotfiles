{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland= {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nur.url = "github:nix-community/nur";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    envycontrol.url = "github:bayasdev/envycontrol";
    hardware.url = "github:nixos/nixos-hardware";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    ags.url = "github:Aylur/ags";
  };


  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        #"aarch64-darwin"
      ];
      inherit (nixpkgs) lib;
      configVars = import ./vars { inherit inputs lib; };
      configLib = import ./lib { inherit lib; };
      # specialArgs = { inherit inputs outputs configVars configLib nixpkgs; };
    in
    {
      # nixosModules = import ./modules/nixos;
      # homeManagerModules = import ./modules/home-manager;

      overlays = import ./overlays { inherit inputs outputs; };

      packages = forAllSystems
        (system:
          let pkgs = nixpkgs.legacyPackages.${system};
          in import ./pkgs { inherit pkgs; }
        );

      formatter = forAllSystems
        (system:
          nixpkgs.legacyPackages.${system}.nixpkgs-fmt
        );

      nixosConfigurations = {
        odin = lib.nixosSystem rec {
          specialArgs = {
            hostName = "odin";
            inherit inputs outputs configVars configLib nixpkgs;
          };

          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
            }

            ./hosts/odin
          ];
        };

        axilon = lib.nixosSystem rec {
          specialArgs = {
            hostName = "axilon";
            inherit inputs outputs configVars configLib nixpkgs;
          };

          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = specialArgs;
            }

            ./hosts/axilon
          ];
        };
      };
    };
}

