{ pkgs, ... }: {
  services.flatpak.enable = true;

  # install flatpak  and set up the flathub repository
  environment.systemPackages = with pkgs; [
    flatpak
  ];

  environment.extraInit = ''
    # Add flathub repository
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    # Install some flatpak apps
    flatpak install flathub org.gnome.Calculator
    flatpak install flathub org.gnome.Loupe
    flatpak install flathub org.gnome.Cheese
  '';
}
