{ lib, ... }:
{
  imports = [ ./audio ./bluetooth ./network ];
  # services.fstrim.enable = lib.mkDefault true;
}
