{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
{
  _module.args.base16-lib = inputs.base16.lib { inherit pkgs lib; };

  imports = [
    ./options.nix
    ./switcher.nix
  ]
  ++ lib.mapAttrsToList (name: _: ./targets + "/${name}") (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./targets)
  );
}
