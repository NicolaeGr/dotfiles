{
  lib,
  pkgs,
  config,
  ...
}:
{

  local.theming = {
    enable = true;

    iconTheme = {
      name = "kora";
      package = pkgs.kora-icon-theme;
    };

    cursorTheme = {
      name = "rose-pine-hyprcursor";
      package = pkgs.rose-pine-hyprcursor;
      size = 24;
    };

    themes = {
      "pretty-purple" = {
        variant = "dark";
        colors = {
          base00 = "#241f31";
          base01 = "#363141";
          base02 = "#332b45";
          base03 = "#5e5c64";
          base04 = "#c0bfbc";
          base05 = "#ffffff";
          base06 = "#f6f5f4";
          base07 = "#ffffff";
          base08 = "#ff5370";
          base09 = "#f8e45c";
          base0A = "#f9f06b";
          base0B = "#8ff0a4";
          base0C = "#26a269";
          base0D = "#9141ac";
          base0E = "#f8e45c";
          base0F = "#ab7967";
        };
      };
      "sagelight" = {
        variant = "light";
        colors = {
          base00 = "#f8f8f8";
          base01 = "#e8e8e8";
          base02 = "#d8d8d8";
          base03 = "#b8b8b8";
          base04 = "#585858";
          base05 = "#383838";
          base06 = "#282828";
          base07 = "#181818";
          base08 = "#fa8480";
          base09 = "#ffaa61";
          base0A = "#ffdc61";
          base0B = "#a0d2c8";
          base0C = "#a2d6f5";
          base0D = "#a0a7d2";
          base0E = "#c8a0d2";
          base0F = "#d2b2a0";
        };
      };
    };
  };
}
