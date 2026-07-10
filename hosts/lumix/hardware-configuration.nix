{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];

  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];

  powerManagement.cpuFreqGovernor = "schedutil";

  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [
    "vm.panic_on_oom=1"
    "kernel.panic=10"
    "intel_pstate=active"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1b4b2f26-ac69-4b6b-90fe-dd9d70a2e8bb";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/1b4b2f26-ac69-4b6b-90fe-dd9d70a2e8bb";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/1b4b2f26-ac69-4b6b-90fe-dd9d70a2e8bb";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/12CE-A600";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/storage" = {
    device = "/dev/disk/by-uuid/065df52d-5eb8-4d0d-ab3d-e69133825609";
    fsType = "ext4";
    options = [
      "noatime"
      "data=ordered"
    ];
  };

  # # Makes /storage sticky. New files stay in 'users' group
  systemd.services.setup-storage-perms = {
    script = ''
      chmod g+s /storage

      chown root:users /storage
      chmod 0777 /storage
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStartPre = "-/bin/chmod 0777 /storage";
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
