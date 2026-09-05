{ ... }: {
  environment.sessionVariables = {
    WAYLAND_DISPLAY = "wayland-1";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    XDG_DOWNLOAD_DIR = "$HOME/Downloads";

    XDG_DOCUMENTS_DIR = "$HOME/Documents";
    XDG_PUBLICSHARE_DIR = "$HOME/Documents/Public";

    XDG_PROJECTS_DIR = "$HOME/Projects";

    XDG_MUSIC_DIR = "$HOME/Media/music";
    XDG_VIDEOS_DIR = "$HOME/Media/videos";
    XDG_PICTURES_DIR = "$HOME/Media/pictures";
    XDG_SCREENSHOTS_DIR = "$HOME/Media/pictures/Screenshots";

    XDG_DESKTOP_DIR = "$HOME/Applications";
    XDG_TEMPLATES_DIR = "$HOME";
  };

  files = {
    ".config/user-dirs.dirs".text = ''
      XDG_DESKTOP_DIR="$HOME/Applications"
      XDG_DOWNLOAD_DIR="$HOME/Downloads"
      XDG_DOCUMENTS_DIR="$HOME/Documents"
      XDG_PUBLICSHARE_DIR="$HOME/Documents/Public"
      XDG_PROJECTS_DIR="$HOME/Projects"
      XDG_MUSIC_DIR="$HOME/Media/music"
      XDG_VIDEOS_DIR="$HOME/Media/videos"
      XDG_PICTURES_DIR="$HOME/Media/pictures"
      XDG_SCREENSHOTS_DIR="$HOME/Media/pictures/Screenshots"
      XDG_TEMPLATES_DIR="$HOME"
    '';

    ".local/share/applications/mimeapps.list".text = ''
      [Default Applications]
      # Web Browsing
      text/html=zen.desktop
      x-scheme-handler/http=zen.desktop
      x-scheme-handler/https=zen.desktop
      x-scheme-handler/about=zen.desktop
      x-scheme-handler/unknown=zen.desktop

      # Media & Documents
      image/png=org.gnome.Loupe.desktop
      image/jpeg=org.gnome.Loupe.desktop
      image/webp=org.gnome.Loupe.desktop
      image/gif=org.gnome.Loupe.desktop
      image/svg+xml=org.gnome.Loupe.desktop
      video/mp4=mpv.desktop
      video/mkv=mpv.desktop
      video/webm=mpv.desktop
      audio/mpeg=mpv.desktop
      audio/flac=mpv.desktop
      audio/wav=mpv.desktop
      application/pdf=zen.desktop

      # Development & Text
      text/plain=helix.desktop
      text/markdown=helix.desktop
      application/json=helix.desktop
      text/x-shellscript=helix.desktop

      # File Manager & Archives
      inode/directory=org.gnome.Nautilus.desktop
      application/zip=org.gnome.Nautilus.desktop
      application/x-tar=org.gnome.Nautilus.desktop
    '';
  };

  #XDG Consolidation
  rum-ext.programs.wget = {
    enable = true;

    settings = {
      "hsts-file" = "$XDG_CACHE_HOME/wget-hsts";
    };
  };
}
