{ inputs, ... }:
{
  additions = final: _prev: import ../pkgs { pkgs = final; };

  modifications = final: prev: { };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config = {
        allowUnfree = true;
        # pnpm-10.29.2 is pinned for electron-based apps that haven't
        # migrated past the 10.29.3 breaking change. Remove this once
        # nixpkgs drops the pnpm_10_29_2 variant.
        permittedInsecurePackages = [
          "pnpm-10.29.2"
        ];
      };
    };
  };
}
