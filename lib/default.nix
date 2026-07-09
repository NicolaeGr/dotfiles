{
  lib,
  flakeRoot,
  self,
  configVars,
  ...
}:

rec {
  ifUserGroupExists =
    groups: config: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

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

  mkUser =
    { name, user }:
    { config, ... }:
    let
      inherit (lib) mkIf mkMerge;
    in
    {
      imports = [ (self + "/modules/user/${name}") ];

      config = mkIf user.enable (mkMerge [
        {
          users.users.${name} = {
            isNormalUser = true;
            home = "/home/${name}";
            hashedPasswordFile = user.hashedPasswordFile;
            extraGroups = ifUserGroupExists (configVars.defaultUserGroups ++ user.extraGroups) config;
            openssh.authorizedKeys.keys = user.trustedKeys;
          };

          environment.systemPackages = user.extraConf.packages or [ ];

          hjem.users.${name} = {
            enable = true;
          };
        }
      ]);
    };
}
