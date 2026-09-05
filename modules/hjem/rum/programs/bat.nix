{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.rum-ext.programs.bat;
  fmt = pkgs.formats.keyValue { listsAsDuplicateKeys = true; };

  settingsText = lib.generators.toKeyValue { listsAsDuplicateKeys = true; } (
    lib.mapAttrs' (name: value: lib.nameValuePair ("--" + name) value) cfg.settings
  );
in
{
  options.rum-ext.programs.bat = {
    enable = lib.mkEnableOption "bat";

    package = lib.mkPackageOption pkgs "bat" { };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages like bat-extras (batman, batgrep, etc.)";
    };

    settings = lib.mkOption {
      type = fmt.type;
      default = { };
      description = "Key-value options written as --key=value to ~/.config/bat/config";
    };

    extraOptions = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional text appended to ~/.config/bat/config.";
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ cfg.package ] ++ cfg.extraPackages;

    files.".config/bat/config".text = ''
      ${settingsText}
      ${cfg.extraOptions}
    '';
  };
}
