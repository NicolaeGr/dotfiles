{...}:{
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    
    systemDirs = {
      data = [
        "/usr/share"
        "/usr/local/share"
        "/var/lib/flatpak/exports/share/applications"
      ];
    };
  };
}
