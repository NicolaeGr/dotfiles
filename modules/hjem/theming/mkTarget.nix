{ lib }:
{
  name,
  config,
  switcherScript ? "",
  defaultEnabled ? config.local.theming.enable,
  condition ? true,
  targetConfig ? { },
}:
{
  options.local.theming.targets.${name} = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = defaultEnabled;
      description = "Whether to enable the ${name} theming target.";
    };

    switcherScript = lib.mkOption {
      type = lib.types.lines;
      internal = true;
      default = "";
      description = "Shell fragment run by hjem-theme when this target is enabled.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf condition {
      local.theming.targets.${name}.switcherScript = switcherScript;
    })
    (lib.mkIf (config.local.theming.targets.${name}.enable && condition) targetConfig)
  ];
}
