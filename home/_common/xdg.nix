{ ... }: {
  environment.sessionVariables = {
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
      XDG_TEMPLATES_DIR="$HOME"
    '';
  };
}
