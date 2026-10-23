{
  lib,
  pkgs,
  config,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
in
mkTarget {
  name = "btop";
  inherit config;

  templates = {
    "btop.theme" = ./btop.theme.tpl;
  };

  switcherScript = ''
    conf="$HOME/.config/btop/btop.conf"

    mkdir -p "$HOME/.config/btop/themes"
    ln -sfn "$HT_THEME_DIR/btop.theme" "$HOME/.config/btop/themes/ht.theme"

    if [[ -f $conf ]] && grep -q '^color_theme' "$conf"; then
      ${pkgs.gnused}/bin/sed -i 's/^color_theme[[:space:]]*=.*/color_theme = "ht"/' "$conf"
    else
      if [[ -s $conf && $(tail -c1 "$conf") != $'\n' ]]; then
        printf '\n' >>"$conf"
      fi
      printf 'color_theme = "ht"\n' >>"$conf"
    fi
  '';
}
