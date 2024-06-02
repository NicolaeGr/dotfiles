{ pkgs, inputs, ... }: {
  programs.firefox = {
    enable = true;

    profiles.default = import ./profile.nix {
      inherit pkgs inputs;
      id = 0;
    };

    profiles.school = import ./profile.nix {
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
