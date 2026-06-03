{ pkgs, ... }:
let
  envRoot = builtins.getEnv "FLAKE_ROOT";
  flakeRoot = if envRoot == "" then "/home/nicolae/Projects/dotfiles" else envRoot;
in
{
  systemd.timers.auto-rebuild = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  systemd.services.auto-rebuild = {
    description = "Auto rebuild system from dotfiles if conditions match";

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = flakeRoot;
    };

    environment = {
      FLAKE_ROOT = flakeRoot;
      HOME = "/root";
    };

    path = [
      pkgs.coreutils
      pkgs.git
      pkgs.nh
      pkgs.nix
      pkgs.openssh
      "/run/wrappers"
    ];

    script = ''
      set -euo pipefail

      echo "[+] Checking for updates securely as user 'nicolae'..."

      # Temporarily turn off 'exit on error' so we can catch the skip code
      set +e


      sudo -u nicolae -H --preserve-env=FLAKE_ROOT bash -c '
        cd "$FLAKE_ROOT"

        git diff --quiet || { echo "[!] Local working tree is dirty. Skipping."; exit 2; }
        git diff --cached --quiet || { echo "[!] Local staging area is dirty. Skipping."; exit 2; }

        GIT_SSH_COMMAND="ssh -i /home/nicolae/.ssh/github_dotfiles_deployment -o IdentitiesOnly=yes" git pull --tags

        TAG=$(git tag --points-at HEAD | grep "^buildable-" || true)
        if [ -z "$TAG" ]; then
            echo "[*] Current HEAD is not tagged as buildable. Skipping."
            exit 2
        fi
      '

      PULL_STATUS=$?
      set -e # Turn 'exit on error' back on

      if [ $PULL_STATUS -eq 2 ]; then
        echo "[*] No valid updates to apply. Exiting cleanly with status 0."
        exit 0
      elif [ $PULL_STATUS -ne 0 ]; then
        echo "[!] Git operations failed with error code $PULL_STATUS."
        exit $PULL_STATUS
      fi

      echo "[+] Buildable tag confirmed. Proceeding with system activation natively as root..."

      nh os switch path:${flakeRoot} -- --impure

      echo "[+] System activation successful."
    '';
  };
}
