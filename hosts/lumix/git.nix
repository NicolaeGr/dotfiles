{ pkgs, lib, ... }:
let
  flakeRoot = builtins.getEnv "FLAKE_ROOT";
in
{
  programs.git = lib.mkIf (flakeRoot != "") {
    includes = [
      {
        condition = "gitdir:${flakeRoot}";
        contents = {
          core.sharedRepository = "group";
        };
      }
    ];
  };
}
