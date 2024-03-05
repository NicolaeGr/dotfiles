{
  home.file = {
    "hyprlock.conf" = {
      target = ".config/hypr/hyprlock.conf";
      source = ./hyprlock.conf;
    };
    
    "status.sh" = {
      target = "~/.config/hypr/hyprlock/status.sh";
      source = ./status.sh;
    };
  };


}
