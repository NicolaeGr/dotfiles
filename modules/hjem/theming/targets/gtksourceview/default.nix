{
  lib,
  config,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
in
mkTarget {
  name = "gtksourceview";
  inherit config;

  templates = {
    "gtksourceview.xml" = ./gtksourceview.xml.tpl;
  };

  switcherScript = ''
    mkdir -p "$HOME/.local/share/gtksourceview-4/styles" "$HOME/.local/share/gtksourceview-5/styles"
    ln -sfn "$HT_THEME_DIR/gtksourceview.xml" "$HOME/.local/share/gtksourceview-4/styles/ht.xml"
    ln -sfn "$HT_THEME_DIR/gtksourceview.xml" "$HOME/.local/share/gtksourceview-5/styles/ht.xml"
  '';
}
