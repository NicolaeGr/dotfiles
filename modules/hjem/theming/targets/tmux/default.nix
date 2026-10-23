{
  lib,
  pkgs,
  config,
  ...
}:
let
  mkTarget = import ../../mkTarget.nix { inherit lib; };
in
mkTarget {
  name = "tmux";
  inherit config;

  condition = config.local.dev.enable;

  templates = {
    "tmux.conf" = ./tmux.conf.tpl;
  };

  switcherScript = ''
    tmux_bin=${pkgs.tmux}/bin/tmux

    if "$tmux_bin" list-sessions >/dev/null 2>&1; then
      "$tmux_bin" source-file "$HT_ACTIVE/tmux.conf" >/dev/null 2>&1 || true
    fi
  '';

  targetConfig = {
    files.".config/tmux/tmux.conf".text = ''
      # Managed by ht. Local settings belong in ~/.config/tmux/local.conf.
      if-shell '[ -f ~/.local/state/ht/active/tmux.conf ]' 'source-file ~/.local/state/ht/active/tmux.conf'
      if-shell '[ -f ~/.config/tmux/local.conf ]' 'source-file ~/.config/tmux/local.conf'
    '';
  };
}
