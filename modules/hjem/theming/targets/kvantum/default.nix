{
  lib,
  pkgs,
  config,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };

  qtPluginPath = lib.concatStringsSep ":" [
    "${pkgs.libsForQt5.qtstyleplugin-kvantum}/${pkgs.libsForQt5.qtbase.qtPluginPrefix}"
    "${pkgs.qt6Packages.qtstyleplugin-kvantum}/${pkgs.qt6.qtbase.qtPluginPrefix}"
    "${pkgs.libsForQt5.qt5ct}/${pkgs.libsForQt5.qtbase.qtPluginPrefix}"
    "${pkgs.qt6Packages.qt6ct}/${pkgs.qt6.qtbase.qtPluginPrefix}"
  ];
in
mkTarget {
  name = "kvantum";
  inherit config;

  templates = {
    "HjemTheme.kvconfig" = ./kvconfig.tpl;
    "HjemTheme.svg" = ./kvantum.svg.tpl;
  };

  switcherScript = ''
    mkdir -p "$HOME/.config/Kvantum/HjemTheme"
    ln -sfn "$HT_THEME_DIR/HjemTheme.kvconfig" "$HOME/.config/Kvantum/HjemTheme/HjemTheme.kvconfig"
    ln -sfn "$HT_THEME_DIR/HjemTheme.svg" "$HOME/.config/Kvantum/HjemTheme/HjemTheme.svg"

    if [ "''${HT_VARIANT:-dark}" = "dark" ]; then
      dark_theme="true"
    else
      dark_theme="false"
    fi

    cat >"$HOME/.config/Kvantum/kvantum.kvconfig" <<EOF
    [General]
    theme=HjemTheme
    dark_theme=$dark_theme
    EOF

    ${pkgs.coreutils}/bin/timeout 5 ${pkgs.qt6Packages.qtstyleplugin-kvantum}/bin/kvantummanager --set HjemTheme >/dev/null 2>&1 || true

    if [ -n "''${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
      ${pkgs.coreutils}/bin/timeout 2 ${pkgs.dbus}/bin/dbus-send --session --type=signal /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:0 int32:0 >/dev/null 2>&1 || true
    fi
  '';

  targetConfig = {
    files.".config/qt5ct/qt5ct.conf".text = ''
      [Appearance]
      style=kvantum
      custom_palette=false
    '';

    files.".config/qt6ct/qt6ct.conf".text = ''
      [Appearance]
      style=kvantum
      custom_palette=false
    '';

    files.".config/hypr/hyprland.lua".text = lib.mkAfter ''
      hl.env("QT_STYLE_OVERRIDE", "kvantum")
      hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
      hl.env("QT_PLUGIN_PATH", "${qtPluginPath}")
    '';

    packages = [
      pkgs.libsForQt5.qtstyleplugin-kvantum
      pkgs.qt6Packages.qtstyleplugin-kvantum
      pkgs.libsForQt5.qt5ct
      pkgs.qt6Packages.qt6ct
    ];
  };
}
