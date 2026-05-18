{
  config,
  lib,
  pkgs,
  ...
}:

let
  containerLib = import ./_util.nix { inherit pkgs lib; };
  ip = "192.168.100.22";
in
{
  containers.seanime = containerLib.mkServiceContainer {
    enable = true;
    ip = ip;

    mounts = {
      "/storage" = {
        hostPath = "/storage";
        isReadOnly = false;
      };

      "/dev/dri" = {
        hostPath = "/dev/dri";
        isReadOnly = false;
      };

      "/var/lib/deploy" = {
        hostPath = "/storage/appdata/seanime";
        isReadOnly = false;
      };
    };

    module = {
      hardware.graphics = {
        enable = true;

        extraPackages = with pkgs; [
          intel-media-driver
          libvdpau-va-gl
        ];
      };

      users.users.deploy = {
        isNormalUser = true;
        isSystemUser = lib.mkForce false;

        uid = 1002;

        group = "users";

        home = "/var/lib/deploy";

        createHome = true;

        extraGroups = [
          "video"
          "render"
        ];

        shell = pkgs.bashInteractive;
      };

      environment.systemPackages = with pkgs; [
        mpv
        ffmpeg-full
        intel-gpu-tools
        libva-utils
      ];

      systemd.services.seanime = {
        description = "Seanime";

        after = [ "network.target" ];

        wantedBy = [ "multi-user.target" ];

        path = with pkgs; [
          bash
          coreutils
          mpv
          ffmpeg-full
        ];

        serviceConfig = {
          Type = "simple";

          User = "deploy";
          Group = "users";

          WorkingDirectory = "/var/lib/deploy";

          ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";

          ExecStart = "${pkgs.unstable.seanime}/bin/seanime";

          Restart = "on-failure";

          Environment = [
            "HOME=/var/lib/deploy"
            "XDG_CONFIG_HOME=/var/lib/deploy/.config"
            "XDG_CACHE_HOME=/var/lib/deploy/.cache"
            "XDG_DATA_HOME=/var/lib/deploy/.local/share"

            "LIBVA_DRIVER_NAME=iHD"
            "VAAPI_DRIVER=iHD"
          ];
        };
      };

      networking.firewall.allowedTCPPorts = [ 43211 ];
      networking.firewall.allowedUDPPorts = [ 43211 ];
    };
  };

  services.nginx.virtualHosts."sea.electrolit.biz" = containerLib.withPrivateAccess {
    forceSSL = true;
    useACMEHost = "electrolit.biz";

    locations."/" = {
      proxyPass = "http://${ip}:43211";

      proxyWebsockets = true;

      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
}
