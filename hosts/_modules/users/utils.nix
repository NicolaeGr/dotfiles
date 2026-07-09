{
  lib,
  configVars,
  self,
  config,
  ...
}:
let
  concatGroups = groups: configVars.defaultUserGroups ++ (lib.toList groups);

  enabledUsers = lib.filterAttrs (_: u: u.enable) config.local.users;
in
{
  options = {
    local.users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "Enable user";

            initialPassword = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Initial password for the user, will be hashed and stored in the home directory";
            };

            hashedPasswordFile = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Path to a file containing the hashed password for the user";
            };

            extraGroups = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Extra groups to add the user to";
            };

            trustedKeys = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of trusted ssh keys for the user";
            };

            extraOptions = lib.mkOption {
              type = lib.types.attrs;
              default = { };
              description = "Extra options to pass to the user";
            };
          };
        }
      );
    };
  };

  config = {
    users.users = lib.mapAttrs (name: user: {
      isNormalUser = true;
      home = "/home/${name}";

      initialPassword = user.initialPassword;
      hashedPasswordFile = user.hashedPasswordFile;

      extraGroups = concatGroups user.extraGroups;
      openssh.authorizedKeys.keys = user.trustedKeys;
    }) enabledUsers;

    hjem.users = lib.mapAttrs (name: user: {
      enable = true;
      user = name;
      directory = "/home/${name}";

      imports = [ (self + "/home/${name}") ];
    }) enabledUsers;

    assertions = lib.flatten (
      lib.mapAttrsToList (
        name: user:
        lib.optional (user.initialPassword != null && user.hashedPasswordFile != null) {
          assertion = false;
          message = "User '${name}': cannot set both initialPassword and hashedPasswordFile at the same time";
        }
      ) enabledUsers
    );
  };
}
