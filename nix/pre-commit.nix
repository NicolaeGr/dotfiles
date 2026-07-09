{ inputs, ... }: {
  perSystem = { system, ... }: {
    checks.pre-commit-check = inputs.git-hooks-nix.lib.${system}.run {
      src = ./.;
      default_stages = [ "pre-commit" ];

      hooks = {
        shfmt.enable = true;
        nixfmt.enable = true;

        end-of-file-fixer.enable = true;
        mixed-line-endings.enable = true;
        detect-private-keys.enable = true;
        check-case-conflicts.enable = true;
        check-merge-conflicts.enable = true;
        fix-byte-order-marker.enable = true;
        trim-trailing-whitespace.enable = true;
        check-executables-have-shebangs.enable = true;
        check-shebang-scripts-are-executable.enable = false;
      };
    };
  };
}
