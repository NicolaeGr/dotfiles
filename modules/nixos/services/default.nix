{ configLib, ... }:
{
  imports = [
    ./options.nix
    ./realize.nix
  ]
  ++ (configLib.scanPaths ./catalog);
}
