{
  lib,
  config,
  inputs,
  outputs,
  ...
}:
{
  sops.secrets."flake_gh_access_key" = { };
  sops.templates."flake_gh_access_file.nix" = {
    content = ''
      access-tokens = github.com=${config.sops.placeholder."flake_gh_access_key"}
    '';
    owner = "root";
    group = "users";
    mode = "0440";
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config.allowUnfree = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 20d --keep 10";
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    settings = {
      connect-timeout = 5;
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;

      substituters = [
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-substituters = [
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    extraOptions = ''
      !include ${config.sops.templates."flake_gh_access_file.nix".path}
    '';
  };
}
