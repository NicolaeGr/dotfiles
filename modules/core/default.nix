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

    mission-center

    # Archive
    zip
    xz
    unzip
    p7zip

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

    #Browser
    firefox
    telegram-desktop

    steam
    r2modman
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
