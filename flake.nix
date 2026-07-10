{
  description = "Pruple Dotfiles v3.0";

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      git-hooks-nix,
      hjem,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./nix/pre-commit.nix
        ./nix/devshell.nix
      ];

      flake =
        let
          inherit (self) outputs;
          lib = nixpkgs.lib;

          flakeRoot = if builtins.pathExists ./.flake-root.nix then import ./.flake-root.nix else null;

          configVars = (import ./vars { inherit inputs lib; }) // {
            inherit flakeRoot;
          };

          configLib = import ./lib { inherit lib flakeRoot; };

          specialArgs = {
            inherit
              inputs
              outputs
              configVars
              configLib
              nixpkgs
              self
              ;
          };

          mkHost =
            hostName:
            lib.nixosSystem {
              specialArgs = specialArgs // {
                inherit hostName;
              };
              modules = [
                hjem.nixosModules.default
                { hjem.specialArgs = { inherit configLib configVars; }; }
                ./hosts/${hostName}
              ];
            };
        in
        {
          nixosConfigurations = {
            odin = mkHost "odin";
            zoln = mkHost "zoln";
            lumix = mkHost "lumix";
          };

          nixosModules = import ./modules/nixos;
          overlays = import ./nix/overlays.nix { inherit inputs outputs; };
          formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
        };
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    hardware.url = "github:nixos/nixos-hardware";

    flake-parts.url = "github:hercules-ci/flake-parts";

    hjem.follows = "hjem-rum/hjem";
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
