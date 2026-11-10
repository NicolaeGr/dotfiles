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

    svc = {
      subnet = "10.200.0.0/24";
      serverIp = "10.200.0.1";
    };

    wg = {
      subnet = "10.100.0.0/16";
      serverIp = "10.100.0.1";
      endpoint = "electrolit.biz";
    };

    tiers = {
      lan = [ "192.168.100.0/24" ];
      admin = [ "10.100.0.0/24" ];
      friends = [ "10.100.1.0/24" ];
    };
  };
}
