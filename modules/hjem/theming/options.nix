{ lib, config, ... }:
with lib;
let
  cfg = config.hjem.theming;

  colorSubmodule = {
    options = listToAttrs (
      map
        (num: {
          name = "base0${num}";
          value = mkOption {
            type = types.strMatching "#[0-9a-fA-F]{6}";
            description = "Base16 color palette coordinate base0${num}.";
          };
        })
        [
          "0"
          "1"
          "2"
          "3"
          "4"
          "5"
          "6"
          "7"
          "8"
          "9"
          "A"
          "B"
          "C"
          "D"
          "E"
          "F"
        ]
    );
  };

  themeSubmodule = { name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
        description = "The display name of the theme.";
      };
      variant = mkOption {
        type = types.enum [
          "dark"
          "light"
        ];
        description = "Context indicator for targeting scripts.";
      };
      colors = mkOption {
        type = types.submodule colorSubmodule;
        description = "Strict Base16 color palette scheme.";
      };
    };
  };
in
{
  options.local.theming = {
    enable = mkEnableOption "custom declarative engine-agnostic system theming";

    themes = mkOption {
      type = types.attrsOf (types.submodule themeSubmodule);
      default = { };
      description = "The complete set of pre-compiled system themes.";
    };
  };
}
