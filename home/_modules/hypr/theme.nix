{
  lib,
  pkgs,
  config,
  ...
}:
{
  packages = with pkgs; [
    rose-pine-hyprcursor
    kora-icon-theme
  ];

  local.theming = {
    enable = true;
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

  files = {
    ".config/hypr/hyprland.lua".text = lib.mkAfter ''
      hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
      hl.env("HYPRCURSOR_SIZE", "24")
    '';

    ".config/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name = kora
      gtk-cursor-theme-name = rose-pine-hyprcursor
      gtk-cursor-theme-size = 24
      gtk-font-name = Sans 10
    '';

    ".config/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name = kora
      gtk-cursor-theme-name = rose-pine-hyprcursor
      gtk-cursor-theme-size = 24
      gtk-font-name = Sans 10
    '';

    ".config/kitty/kitty.conf".text = lib.mkAfter ''
      # Read the currently active theme
      include ${config.directory}/.config/hjem/themes/active/kitty.conf

      # Enable IPC for the live-reload script
      allow_remote_control yes
      listen_on unix:/tmp/kitty
    '';

    ".config/gtk-3.0/gtk.css".text = ''
      @import url("file://${config.directory}/.config/hjem/themes/active/gtk.css");
    '';

    ".config/gtk-4.0/gtk.css".text = ''
      @import url("file://${config.directory}/.config/hjem/themes/active/gtk.css");
    '';
  };
}
