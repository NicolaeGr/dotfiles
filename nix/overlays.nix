{ inputs, ... }:
{
  additions = final: _prev: import ./pkgs { pkgs = final; };

  modifications = final: prev: {
    # The vial AppImage ships libgcrypt and libsystemd but, per the AppImage
    # excludelist, no libgpg-error. appimageTools' FHS env does not provide it,
    # so libqxcb.so fails to load and Qt reports a missing "xcb" plugin.
    vial = prev.vial.override {
      appimageTools = prev.appimageTools // {
        wrapType2 =
          args:
          prev.appimageTools.wrapType2 (
            args
            // {
              extraPkgs = p: [ p.libgpg-error ];
            }
          );
      };
    };
  };

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
