{ pkgs, ... }:
let
  flakeRoot = builtins.getEnv "FLAKE_ROOT";
in
{
  systemd.services.auto-rebuild = {
    description = "Auto rebuild system from dotfiles if conditions match";

    serviceConfig = {
      Type = "oneshot";
      User = "nicolae";
      WorkingDirectory = flakeRoot;
    };

    environment = {
      HOME = "/home/nicolae";
      DOTFILES = flakeRoot;
    };

    path = [
      pkgs.coreutils
      pkgs.git
      pkgs.nh
      pkgs.nix
      pkgs.openssh
      pkgs.gnutar
      pkgs.gzip
      pkgs.bash
      pkgs.just
      pkgs.sudo
    ];

    script = ''
      set -euo pipefail

      git diff --quiet || { echo "[!] Local working tree is dirty. Aborting auto-update."; exit 0; }
      git diff --cached --quiet || { echo "[!] Local staging area is dirty. Aborting auto-update."; exit 0; }

      GIT_SSH_COMMAND="ssh -i /home/nicolae/.ssh/github_dotfiles_deployment -o IdentitiesOnly=yes" git pull --tags

      TAG=$(git tag --points-at HEAD | grep '^buildable-' || true)

      if [ -z "$TAG" ]; then
          echo "[*] Current HEAD is not tagged as buildable. Nothing to do."
          exit 0
      fi

      echo "[+] Buildable tag found ($TAG). Running rebuild..."
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
      users = [ "nicolae" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
