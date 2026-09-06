{
  lib,
  pkgs,
  config,
  base16-lib,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
  cfg = config.local.theming;
in
mkTarget {
  name = "kitty";
  inherit config;
  switcherScript = ''
    if [ -S /tmp/kitty ]; then
      ${pkgs.kitty}/bin/kitty @ --to unix:/tmp/kitty set-colors -a -c "$ACTIVE_DIR/kitty.conf" || true
      ${pkgs.kitty}/bin/kitty @ --to unix:/tmp/kitty load-config "$HOME/.config/kitty/kitty.conf" || true
    fi
  '';
  targetConfig = {
    xdg.config.files = lib.mapAttrs' (
      themeName: theme:
      let
        colors = (base16-lib.mkSchemeAttrs theme.colors).override { };
      in
      lib.nameValuePair "hjem/themes/${themeName}/kitty.conf" {
        source = colors {
          template = ./kitty.conf.mustache;
          extension = ".conf";
        };
      }
    ) cfg.themes;

    files.".config/kitty/kitty.conf".text = lib.mkAfter ''
      include ${config.directory}/.config/hjem/themes/active/kitty.conf

      allow_remote_control yes
      listen_on unix:/tmp/kitty
    '';
  };
}
