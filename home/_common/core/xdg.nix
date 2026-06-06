{ config, ... }:
{
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      desktop = "${config.home.homeDirectory}/.desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Media/audio";
      pictures = "${config.home.homeDirectory}/Media/images";
      videos = "${config.home.homeDirectory}/Media/video";

      extraConfig = {
        PUBLICSHARE = "/var/empty";
        TEMPLATES = "/var/empty";
      };
    };

    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

        "text/html" = [ "app.zen_browser.zen.desktop" ];
        "application/pdf" = [ "app.zen_browser.zen.desktop" ];
        "x-scheme-handler/http" = [ "app.zen_browser.zen.desktop" ];
        "x-scheme-handler/https" = [ "app.zen_browser.zen.desktop" ];
        "x-schema-handler/about" = [ "app.zen_browser.zen.desktop" ];
        "application/vnd.mozilla.xul+xml" = [ "app.zen_browser.zen.desktop" ];

        "text/*" = [ "code.desktop" ];
        "image/*" = [ "org.gnome.Loupe.desktop" ];
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
