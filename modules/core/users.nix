{ inputs, pkgs, system, nix-flatpak, ... }: {

  users.users = {
    pruple = {
      isNormalUser = true;
      home = "/home/pruple";
      shell = pkgs.zsh;

      extraGroups = [ "wheel" "networkmanager" "audio" "video" "render" "input" "storage" "users" "power" "libvirt" "docker" ];
    };

    nicolae = {
      isNormalUser = true;
      home = "/home/nicolae";
      shell = pkgs.zsh;

      extraGroups = [ "wheel" "networkmanager" "audio" "video" "render" "input" "storage" "users" "power" "libvirt" "docker" ];
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit system inputs;
    };

    users = {
      pruple = {
        imports = [
          ./../../home/pruple
        ];

        home.stateVersion = "23.11";

        programs.home-manager.enable = true;
      };

      nicolae = {
        imports = [
          ./../../home/nicolae
        ];

        home.stateVersion = "23.11";

        programs.home-manager.enable = true;
      };
    };
  };
}
