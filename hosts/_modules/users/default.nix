{
  self,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./utils.nix
  ];

  config = {
    sops.secrets = {
      "passwords/nicolae" = {
        neededForUsers = true;
      };
    };

    hjem = {
      clobberByDefault = true;

      extraModules = [
        inputs.hjem-rum.hjemModules.default
        (self + "/home/_common")
      ];
    };

    local.users.nicolae = {
      enable = true;
      hashedPasswordFile = config.sops.secrets."passwords/nicolae".path;
      extraGroups = [ "wheel" ];
      trustedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXCGZ+GCIYb5Kwv73T9GXn0zfF8VORf6HDjx39R+KgP nicolae@odin"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfDaSjtslSu+N7+NRTVU2dycXsfgpfzzVmNBkgVWJWO nicolae@zoln"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5NCnQC9er7RFTgS6HD1yVVMkq5eor9EiaDkrTsGZzb nicolae@sweet"
      ];
    };
  };
}
