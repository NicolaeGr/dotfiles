{ inputs, lib, pkgs, ... }: {

  system.stateVersion = "23.11";

  # Move from here
  programs.zsh.enable = true;

  imports = [ ./users.nix ./fonts ];

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.printing.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    xorg.xbacklight
    auto-cpufreq
    lshw

    # Editors
    vim
    neovim

    # Utils
    neofetch
    wget
    curl
    git
    man
    ripgrep
    jq
    eza
    fzf

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

    # Programming
    gcc
    rustup
    glow
    btop
    iotop
    iftop

    vscodium

    # Work
    obsidian
    onlyoffice-bin

    nvtop-amd

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

}
