{ ... }: {
  perSystem = { config, pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      NIX_CONFIG = "extra-experimental-features = nix-command flakes";

      buildInputs = config.checks.pre-commit-check.enabledPackages;

      shellHook = ''
        ${config.checks.pre-commit-check.shellHook}
        git config --local push.followTags true
      '';

      nativeBuildInputs = with pkgs; [
        nix
        git
        just
        nixfmt
        nil

        age
        ssh-to-age
        sops
      ];
    };
  };
}
