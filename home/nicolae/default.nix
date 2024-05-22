{ configLib, outputs, ... }: {

  imports = [
    (configLib.relativeToRoot "modules/home-manager")
  ];


  home.username = "nicolae";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

}
