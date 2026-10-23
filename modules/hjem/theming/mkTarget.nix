# Register one theming target.
#
# A target directory contains this file and one or more .tpl files. The
# template map is output path -> template path. If a target needs a switch
# action longer than a few lines, pass switcher = ./switch.sh instead of
# switcherScript.
{ lib }:
{
  name,
  config,
  templates,
  defaultEnabled ? config.local.theming.enable,
  condition ? true,
  switcher ? null,
  switcherScript ? "",
  targetConfig ? { },
  packages ? [ ],
}:
let
  enabled = config.local.theming.targets.${name}.enable && condition;
in
{
  options.local.theming.targets.${name}.enable = lib.mkOption {
    type = lib.types.bool;
    default = defaultEnabled;
    description = "Whether to enable the ${name} theming target.";
  };

  config = lib.mkMerge [
    (lib.mkIf enabled {
      local.theming._targets.${name} = {
        inherit
          name
          templates
          packages
          switcherScript
          ;
        inherit switcher;
      };
    })
    (lib.mkIf enabled targetConfig)
  ];
}
