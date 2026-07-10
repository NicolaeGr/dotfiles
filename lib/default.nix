{ lib, ... }:
{
  relativeToRoot = path: ./. + "/../${path}";
  ifUserGroupExists =
    groups: config: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") || ((path != "default.nix") && (lib.strings.hasSuffix ".nix" path))
        ) (builtins.readDir path)
      )
    );
}
