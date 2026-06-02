{ ... }:
{

  options.extra.gamesave.enable = lib.mkEnableOption {
    default = true;
    description = "Enable game save features";
  };

  config = lib.mkIf config.extra.gamesave.enable {
    home.packages = with pkgs; [
      unstable.ludusavi
    ];
  };
}
