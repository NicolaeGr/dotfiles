{ lib, ... }:
{
  relativeToRoot = lib.path.append ../.;

  ifUserGroupExists = groups: config: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
}
