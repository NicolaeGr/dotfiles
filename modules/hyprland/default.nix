{ inputs, lib, pkgs, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware = {
    opengl.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];

  services.xserver.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  
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
  
  # TODO: Move light to it's own file
  programs.light.enable = true;
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          options = [ "NOPASSWD" ];
          command = "${pkgs.light}/bin/light";
        }
      ];
    }
  ];

  # Hyprlock
  environment.systemPackages = with pkgs; [ hyprlock hyprshot hypridle ];

  services.xserver.libinput.enable = true;
}
