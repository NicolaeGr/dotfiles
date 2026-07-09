{
  lib,
  flakeRoot,
  ...
}:
{
  scanPaths =
    path:
    let
      entries = builtins.readDir path;
    in
    lib.pipe entries [
      (lib.filterAttrs (
        name: type:
        if type == "directory" then
          (builtins.readDir (path + "/${name}")) ? "default.nix"
        else
          name != "default.nix" && lib.hasSuffix ".nix" name
      ))
      builtins.attrNames
      (map (name: path + "/${name}"))
    ];

  outOfStorePath =
    storePath:
    let
      relPath = builtins.head (builtins.match ".*/[^/]+-source/(.*)" (builtins.toString storePath));
    in
    if flakeRoot != null && relPath != null then "${flakeRoot}/${relPath}" else storePath;
}
