{
  lib,
  config,
  base16-lib,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
  cfg = config.local.theming;
in
mkTarget {
  name = "gtksourceview";
  inherit config;

  switcherScript = ''
    mkdir -p "$HOME/.local/share/gtksourceview-4/styles" "$HOME/.local/share/gtksourceview-5/styles"
    ln -sfn "$ACTIVE_DIR/gtksourceview.xml" "$HOME/.local/share/gtksourceview-4/styles/hjem.xml"
    ln -sfn "$ACTIVE_DIR/gtksourceview.xml" "$HOME/.local/share/gtksourceview-5/styles/hjem.xml"
  '';

  targetConfig = {
    xdg.config.files = lib.mapAttrs' (
      themeName: theme:
      let
        colors = (base16-lib.mkSchemeAttrs theme.colors).override { };
      in
      lib.nameValuePair "hjem/themes/${themeName}/gtksourceview.xml" {
        source = colors {
          template = ./gtksourceview.xml.mustache;
          extension = ".xml";
        };
      }
    ) cfg.themes;
  };
}
