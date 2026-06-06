{
  lib,
  pkgs,
  outputs,
  configLib,
  ...
}:
{
  imports = (configLib.scanPaths ./.) ++ (builtins.attrValues outputs.homeManagerModules);

  services.ssh-agent.enable = true;

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };

  programs = {
    home-manager.enable = true;
  };

  systemd.user.startServices = "sd-switch";

  home = {
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      TERM = "kitty";
      TERMINAL = "kitty";
      VISUAL = "nvim";
      EDITOR = "nvim";
      MANPAGER = "batman";
    };
    preferXdgDirectories = true;
    shell.enableZshIntegration = true;

    stateVersion = "26.05";
  };
}
