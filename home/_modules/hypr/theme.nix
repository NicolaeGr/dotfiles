{ lib, pkgs, ... }: {
  packages = with pkgs; [
    rose-pine-hyprcursor
    kora-icon-theme
  ];

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

    # ".config/gtk-3.0/gtk.css".text = ''
    #   @import url("file:///home/nicolae/.local/state/nosh/active-theme/gtk-3.0/gtk.css");
    # '';
    # ".config/gtk-4.0/gtk.css".text = ''
    #   @import url("file:///home/nicolae/.local/state/nosh/active-theme/gtk-4.0/gtk.css");
    # '';

    # ".config/kitty/kitty.conf".text = ''
    #   # Static physical configurations
    #   font_family      FiraCode Nerd Font
    #   font_size        11.0
    #   cursor_shape     underline
    #   shell_integration disabled

    #   # Dynamic color override hook
    #   include /home/nicolae/.local/state/nosh/active-theme/kitty/colors.conf
    # '';
  };
}
