{ config, pkgs, username, inputs, ... }: {
  imports = [ ./../config ./../config/hyprland ];

  home.username = "nicolae";
  home.homeDirectory = "/home/nicolae";

  home.packages = with pkgs; [
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    NIXOS_OZONE_WL = "1";
    WLD_NO_HARDWARE_CURSORS = "1";
  };

  home.file = { };

  programs.firefox = {
    enable = true;

    profiles.default = import ./../config/firefox {
      inherit pkgs inputs;
      id = 0;
    };
    profiles.school = import ./../config/firefox {
      inherit pkgs inputs;
      id = 1;
    };

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "never";

      Preferences = { };
    };
  };
}

