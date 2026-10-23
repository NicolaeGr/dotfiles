{
  lib,
  pkgs,
  config,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
  cfg = config.local.theming;
in
mkTarget {
  name = "gtk";
  inherit config;

  templates = {
    "gtk.css" = ./gtk.css.tpl;
  };

  switcherScript = ''
    if [ "''${HT_VARIANT:-dark}" = "light" ]; then
      gtk_theme="adw-gtk3"
      scheme="default"
      prefer_dark="0"
    else
      gtk_theme="adw-gtk3-dark"
      scheme="prefer-dark"
      prefer_dark="1"
    fi

    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'$scheme'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'$gtk_theme'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme ${lib.escapeShellArg "'${cfg.iconTheme.name}'"}
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-theme ${lib.escapeShellArg "'${cfg.cursorTheme.name}'"}
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-size ${toString cfg.cursorTheme.size}

    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    for version in 3.0 4.0; do
      cat >"$HOME/.config/gtk-$version/settings.ini" <<EOF
    [Settings]
    gtk-theme-name=$gtk_theme
    gtk-icon-theme-name=${cfg.iconTheme.name}
    gtk-cursor-theme-name=${cfg.cursorTheme.name}
    gtk-cursor-theme-size=${toString cfg.cursorTheme.size}
    gtk-font-name=${cfg.fonts.sansSerif} ${toString cfg.fonts.sansSize}
    gtk-application-prefer-dark-theme=$prefer_dark
    EOF
    done
  '';

  targetConfig = {
    packages = [ pkgs.adw-gtk3 ];

    files.".config/gtk-3.0/gtk.css".text = ''
      @import url("${config.directory}/.local/state/ht/active/gtk.css");
    '';
    files.".config/gtk-4.0/gtk.css".text = ''
      @import url("${config.directory}/.local/state/ht/active/gtk.css");
    '';
  };
}
