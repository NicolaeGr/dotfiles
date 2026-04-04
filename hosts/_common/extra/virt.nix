{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.extra.virt.enable = lib.mkEnableOption {
    description = "Enable virtualization support";
    default = false;
  };

  config = lib.mkIf config.extra.virt.enable {

    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      virt-manager
    ];
  };
}
