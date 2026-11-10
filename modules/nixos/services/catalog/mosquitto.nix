{
  local.platform.services.mosquitto = {
    host = "lumix";
    address = "10.200.0.32";
    ports.mqtt = 1883;
    ingress.internal.mqtt.port = "mqtt";

    container = {
      mounts."/var/lib/mosquitto" = {
        hostPath = "/storage/appdata/mosquitto";
        isReadOnly = false;
      };

      module =
        { svc, ... }:
        {
          services.mosquitto = {
            enable = true;
            listeners = [
              {
                port = svc.ports.mqtt;
                omitPasswordAuth = true;
                settings.allow_anonymous = true;
                acl = [ "pattern readwrite #" ];
              }
            ];
          };

          networking.firewall.allowedTCPPorts = [ svc.ports.mqtt ];
        };
    };
  };
}
