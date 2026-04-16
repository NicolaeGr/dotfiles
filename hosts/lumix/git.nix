{ pkgs, lib, ... }:
let
  flakeRoot = builtins.getEnv "FLAKE_ROOT";
in
{
  programs.git = lib.mkIf (flakeRoot != "") {
    includes = [
      {
        condition = "gitdir:${flakeRoot}";
        contents = {
          core.sharedRepository = "group";
        };
      }
    ];
  };

  systemd.services.auto-rebuild = {
    description = "Auto rebuild system from dotfiles if conditions match";

    serviceConfig = {
      Type = "oneshot";
      User = "deploy";
    };

    script = ''
      set -euo pipefail

      cd "$DOTFILES"

      git diff --quiet || exit 0

      git pull --tags

      TAG=$(git tag --points-at HEAD | grep '^buildable-' || true)

      [ -z "$TAG" ] && exit 0

      just rebuild
    '';
  };

  security.sudo.extraRules = [
    {
      users = [ "deploy" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
