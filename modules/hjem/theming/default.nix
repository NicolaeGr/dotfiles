{
  lib,
  pkgs,
  inputs,
  config,
  configLib,
  ...
}:
let
  cfg = config.local.theming;
in
{
  _module.args.base16-lib = inputs.base16.lib { inherit pkgs lib; };
  imports = lib.flatten [
    ./options.nix
    ./switcher.nix
    (configLib.scanPaths ./targets)
  ];
}
