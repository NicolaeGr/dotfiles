{ pkgs, lib, ... }:
let
  flakeRoot = builtins.getEnv "FLAKE_ROOT";
in
{
  home-manager.sharedModules = [
    ({
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
    })
  ];

  systemd.services.auto-rebuild = {
    description = "Auto rebuild system from dotfiles if conditions match";

    serviceConfig = {
      Type = "oneshot";
      User = "deploy";
    };
    environment = {
      DOTFILES = flakeRoot;
    };
    path = with pkgs; [
      bash
      git
      just
      openssh
      nh
      nix
    ];

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

  systemd.timers.auto-rebuild = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnCalendar = "daily";
      Persistent = true;
    };
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
