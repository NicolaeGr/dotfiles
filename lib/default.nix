{
  lib,
  self,
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
      storePathStr = builtins.toString storePath;
      selfPathStr = builtins.toString self;
      flakeRootStr = builtins.toString flakeRoot;
    in
    if flakeRootStr == "" then
      storePath
    else if lib.hasPrefix selfPathStr storePathStr then
      flakeRootStr
      + builtins.substring (builtins.stringLength selfPathStr) (
        builtins.stringLength storePathStr - builtins.stringLength selfPathStr
      ) storePathStr
    else
      storePath;

}
