{ inputs, options, config, lib, pkgs, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  options = {
    profiles.media.audio.enable = lib.mkEnableOption {
      default = false;
      description = "Enable audio production tools";
    };
  };

  imports = [
    inputs.spicetify-nix.nixosModules.default
  ];

  config = lib.mkIf config.profiles.media.audio.enable {
    environment.systemPackages = with pkgs; [
      spotify
    ];

    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle
        adblock
        autoSkip
        playNext
        # genre
        featureShuffle
      ];
    };
  };
}
