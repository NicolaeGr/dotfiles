{ inputs, pkgs, system, nix-flatpak, ... }: {

  users.users = {
    # root = {
    #   isSystemUser = true;
    #   home = "/root";
    #   shell = pkgs.zsh;
    # };

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
      inherit system;
    };

    users = {
      pruple = {
        imports = [
          # nix-flatpak.homeManagerModules.nix-flatpak

          ./../../home/pruple
        ];

        home.stateVersion = "23.11";

        programs.home-manager.enable = true;
      };

      nicolae = {
        imports = [
          # nix-flatpak.homeManagerModules.nix-flatpak

          ./../../home/nicolae
        ];

        home.stateVersion = "23.11";

        programs.home-manager.enable = true;
      };
    };
  };
}
