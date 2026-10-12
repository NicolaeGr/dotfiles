{ ... }:
{
  defaultUserGroups = [
    "i2c"
    "kvm"
    "audio"
    "video"
    "input"
    "users"
    "power"
    "render"
    "docker"
    "openrgb"
    "libvirt"
    "libvirtd"
    "storage"
    "libvirtd"
    "adbusers"
    "vboxusers"
    "sambashare"
    "networkmanager"
  ];

  net = {
    publicIp = "188.138.145.187";

    gateway = "192.168.100.1";

    lan = {
      subnet = "192.168.100.0/24";
      serverIp = "192.168.100.10";
    };

    wg = {
      subnet = "10.100.0.0/24";
      serverIp = "10.100.0.1";
    };
  };
}
