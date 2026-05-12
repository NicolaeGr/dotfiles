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
      "/storage/media" = {
        hostPath = "/storage/media";
        isReadOnly = false;
      };

      "/dev/dri" = {
        hostPath = "/dev/dri";
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

      users.users.deploy.extraGroups = [
        "video"
        "render"
      ];

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

          ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";

          ExecStart = "${pkgs.unstable.seanime}/bin/seanime";

          Restart = "on-failure";

          User = "deploy";
          Group = "users";

          Environment = [
            "LIBVA_DRIVER_NAME=iHD"
            "VAAPI_DRIVER=iHD"
          ];
        };
      };
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
