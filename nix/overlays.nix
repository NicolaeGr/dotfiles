{ inputs, ... }:
{
  additions = final: _prev: import ./pkgs { pkgs = final; };

  modifications = final: prev: { };

  master-hotfixes = final: _prev: {
    master = import inputs.nixpkgs {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
