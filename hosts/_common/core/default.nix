{
  lib,
  inputs,
  outputs,
  configLib,
  ...
}:
{
  imports = lib.flatten [
    (configLib.scanPaths ./.)
    inputs.home-manager.nixosModules.home-manager
    (builtins.attrValues outputs.nixosModules)
  ];

  config = {
    services.dbus.enable = true;
    services.avahi = {
      enable = true;
      nssmdns = true;
    };

    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = lib.mkDefault 10;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    boot.initrd = {
      systemd.enable = true;
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 20d --keep 20";
    };

    nixpkgs = {
      overlays = builtins.attrValues outputs.overlays;
      config = {
        allowUnfree = true;
      };

      hostPlatform = lib.mkDefault "x86_64-linux";
    };

    programs.mtr.enable = true;
    services.upower.enable = true;

    programs.gnupg.agent.enable = true;
    programs.ssh.extraConfig = ''
      AddKeysToAgent yes
    '';

    services.openssh = {
      enable = true;

      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      settings.PermitRootLogin = "no";
    };

    security.sudo.extraConfig = ''
      Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
      Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
      # Keep SSH_AUTH_SOCK so that pam_ssh_agent_auth.so can do its magic.
      Defaults env_keep+=SSH_AUTH_SOCK
    '';

    hardware.enableRedistributableFirmware = true;

    system.stateVersion = "25.05";
  };
}
