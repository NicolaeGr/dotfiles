{ inputs, outputs, lib, pkgs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./nix.nix
    ./locale.nix
    ./backlight.nix
    ./xdg.nix
    ./fonts.nix
    ./zsh.nix

    ./dev
    ./flatpak
    ./hardware
  ];

  # Activate modules that need to be on by default.
  backlight.enable = lib.mkDefault true;
  xdg.enable = lib.mkDefault true;
  fonts.enable = lib.mkDefault true;
  zsh.enable = lib.mkDefault true;
  flatpak.enable = lib.mkDefault true;

  # Global config #
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true;
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    lshw
    auto-cpufreq

    # Utils
    neofetch
    wget
    curl
    git
    man
    jq
    unstable.dust

    # Archive
    zip
    xz
    unzip
    p7zip

    # System Monitor
    htop
    unstable.btop
    nethogs

    # Auto Mount
    udisks2
    udiskie

    #Browser
    firefox
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


  system.stateVersion = "23.11";
}
