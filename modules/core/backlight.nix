{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    xorg.xbacklight
  ];

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
}
