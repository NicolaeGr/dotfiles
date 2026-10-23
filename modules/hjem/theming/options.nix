# Options for the ht theming engine.
#
# Themes use Omarchy's colors.toml vocabulary. A theme either points at a
# colors.toml file or declares the same keys inline.
{
  lib,
  ...
}:
with lib;
let
  colorValue = types.oneOf [
    types.str
    types.int
    types.float
    types.bool
  ];

  themesDir = ./themes;

  builtinThemes =
    lib.mapAttrs'
      (
        file: _: lib.nameValuePair (lib.removeSuffix ".toml" file) { colorsFile = themesDir + "/${file}"; }
      )
      (
        lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".toml" name) (
          builtins.readDir themesDir
        )
      );

  themeSubmodule = types.submodule {
    options = {
      colorsFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to a colors.toml file. Takes precedence over colors.";
      };

      colors = mkOption {
        type = types.attrsOf colorValue;
        default = { };
        description = ''
          colors.toml keys. Values may be hex, rgb()/rgba(), gradients, or
          plain strings such as a mode name.
        '';
      };
    };
  };
in
{
  options.local.theming = {
    enable = mkEnableOption "Omarchy-compatible theming";

    default = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Theme name used by ht reload when no theme is active.";
    };

    themes = mkOption {
      type = types.attrsOf themeSubmodule;
      default = builtinThemes;
      description = "The complete set of themes. Defaults to the TOMLs in ./themes.";
    };

    iconTheme = {
      name = mkOption {
        type = types.str;
        default = "Adwaita";
        description = "Icon theme name.";
      };
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Icon theme package.";
      };
    };

    cursorTheme = {
      name = mkOption {
        type = types.str;
        default = "Adwaita";
        description = "Cursor theme name.";
      };
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = "Cursor theme package.";
      };
      size = mkOption {
        type = types.int;
        default = 24;
        description = "Cursor size.";
      };
    };

    fonts = {
      sansSerif = mkOption {
        type = types.str;
        default = "Noto Sans";
        description = "Interface font family.";
      };
      monospace = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Terminal and editor font family.";
      };
      emoji = mkOption {
        type = types.str;
        default = "Noto Color Emoji";
        description = "Emoji font family.";
      };
      sansSize = mkOption {
        type = types.int;
        default = 10;
        description = "Interface font size.";
      };
      monospaceSize = mkOption {
        type = types.int;
        default = 11;
        description = "Terminal font size.";
      };
    };

    # Filled by mkTarget. One entry exists only while the target is enabled.
    _targets = mkOption {
      type = types.attrsOf types.attrs;
      internal = true;
      default = { };
      description = "Enabled target descriptors.";
    };
  };
}
