{
  description = "My First Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    envycontrol.url = "github:bayasdev/envycontrol";

    # NEOVIM PLUGINS
    fine-cmdline-nvim = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };

    lualine-nvim = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... }@inputs:
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
            inherit inputs system nix-flatpak;
          };

          modules = [
            ./modules/core

            home-manager.nixosModules.home-manager
            nix-flatpak.nixosModules.nix-flatpak

            ./modules/hardware
            ./modules/hardware/nvidia
            ./modules/hyprland


            ./hosts/zion
          ];
        };
      };
    };
}

