{ inputs, lib, pkgs, ... }: {
  environment.sessionVariables = rec {
    WLD_NO_HARDWARE_CURSORS = "1";

    NIXOS_OZONE_WL = "1";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware = {
    opengl.enable = true;

    nvidia.modesetting.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.enable = true;

  security.polkit.enable = true;

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  programs.light.enable = true;

  services.xserver.libinput.enable = true;
}
