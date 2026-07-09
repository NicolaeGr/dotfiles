{ self, ... }:
{
  imports = [
    ./hardware-configuration.nix

    (self + "/hosts/_common")
  ];
}
