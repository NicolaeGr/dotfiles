{
  self,
  inputs,
  ...
}:
{
  imports = [
    ./utils.opt.nix
    ./utils.nix
  ];

  config = {
    hjem = {
      clobberByDefault = true;

      extraModules = [
        inputs.hjem-rum.hjemModules.default
        (self + "/home/_common")
      ];
    };

    local.users.nicolae = {
      enable = true;
      initialPassword = "nicolae";
      extraGroups = [ "wheel" ];
      trustedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXCGZ+GCIYb5Kwv73T9GXn0zfF8VORf6HDjx39R+KgP nicolae@odin"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfDaSjtslSu+N7+NRTVU2dycXsfgpfzzVmNBkgVWJWO nicolae@zoln"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5NCnQC9er7RFTgS6HD1yVVMkq5eor9EiaDkrTsGZzb nicolae@sweet"
      ];
    };
  };
}
