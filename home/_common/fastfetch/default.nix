{ configLib, ... }:
{
  rum.programs.fastfetch.enable = true;

  files.".config/fastfetch/config.jsonc".source = configLib.outOfStorePath ./config.jsonc;
}
