{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  cfg = config.local.theming;
in
{
  _module.args.base16-lib = inputs.base16.lib { inherit pkgs lib; };
  imports = [
    ./options.nix
    ./switcher.nix
    ./targets/gtk
    ./targets/gtksourceview
    ./targets/kvantum
    ./targets/kitty
  ];
}
