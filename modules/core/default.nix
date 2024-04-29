{ inputs, lib, pkgs, nixpkgs, ... }: {

  system.stateVersion = "23.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./xdg.nix
    ./users.nix
    ./backlight.nix
    ./fonts
    ./terminal

    ./flatpak
    ./dev
  ];


  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    auto-cpufreq
    lshw

    # Utils
    neofetch
    wget
    curl
    git
    man
    jq
    dust

    # Archive
    zip
    xz
    unzip
    p7zip

    # Hyprland
    polkit
    sddm

    waybar
    kitty

    rofi-wayland

    dunst
    libnotify

    swww

    (waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    })
    )

    # System Monitor
    htop
    btop
    nethogs

    # Work
    obsidian
    onlyoffice-bin

    # Auto Mount
    udisks2
    udiskie
  ];

  services.auto-cpufreq.enable = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  services.printing.enable = true;

  services.gvfs.enable = true;
}
