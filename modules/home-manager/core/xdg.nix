{ ... }: {
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      };
    };
    configFile."mimeapps.list".force = true;

    systemDirs = {
      data = [
        "/usr/share"
        "/usr/local/share"
        "/var/lib/flatpak/exports/share/applications"
      ];
    };
  };
}
