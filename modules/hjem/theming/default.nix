# ht: Omarchy-compatible theming.
#
# Themes render into one store path. ht swaps a symlink to the selected
# theme directory and runs each enabled target's switch hook.
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.local.theming;
  targets = cfg._targets;

  themeNames = builtins.attrNames cfg.themes;
  defaultTheme =
    if cfg.default != null then
      cfg.default
    else if themeNames == [ ] then
      ""
    else
      builtins.head themeNames;

  toToml =
    attrs:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (key: value: "${key} = ${builtins.toJSON value}") attrs
    )
    + "\n";

  colorsFile =
    name: theme:
    pkgs.writeText "ht-colors-${lib.strings.sanitizeDerivationName name}.toml" (
      if theme.colorsFile != null then builtins.readFile theme.colorsFile else toToml theme.colors
    );

  themeData =
    theme:
    if theme.colorsFile != null then
      builtins.fromTOML (builtins.readFile theme.colorsFile)
    else
      theme.colors;

  variantFor =
    theme:
    let
      data = themeData theme;
    in
    data.mode or data.theme_type or "dark";

  renderCommands =
    themeName: theme:
    lib.concatStrings (
      lib.mapAttrsToList (
        _: target:
        lib.concatStrings (
          lib.mapAttrsToList (output: template: ''
            mkdir -p "$out/$(dirname ${lib.escapeShellArg output})"
            ${pkgs.bash}/bin/bash ${./render.sh} \
              --colors ${lib.escapeShellArg (toString (colorsFile themeName theme))} \
              --template ${template} \
              --output "$out/"${lib.escapeShellArg output} \
              --name ${lib.escapeShellArg themeName}
          '') target.templates
        )
      ) targets
    );

  themeDrv =
    themeName: theme:
    pkgs.runCommand "ht-theme-${lib.strings.sanitizeDerivationName themeName}"
      {
        nativeBuildInputs = with pkgs; [
          bash
          coreutils
          gawk
          gnugrep
        ];
      }
      ''
        mkdir -p "$out"
        cp ${lib.escapeShellArg (toString (colorsFile themeName theme))} "$out/colors.toml"
        printf '%s\n' ${lib.escapeShellArg (variantFor theme)} >"$out/variant"
        ${renderCommands themeName theme}
      '';

  themeDrvs = lib.mapAttrs themeDrv cfg.themes;

  hookFor =
    targetName: target:
    if target.switcher != null then
      target.switcher
    else if target.switcherScript != "" then
      pkgs.writeShellScript "ht-${lib.strings.sanitizeDerivationName targetName}" target.switcherScript
    else
      null;

  hookInstall =
    targetName: target:
    let
      hook = hookFor targetName target;
    in
    if hook == null then
      ""
    else
      ''
        install -m755 ${hook} "$out/libexec/${lib.strings.sanitizeDerivationName targetName}.sh"
      '';

  htScript = pkgs.replaceVars ./ht.sh {
    default = defaultTheme;
  };

  ht =
    pkgs.runCommand "ht"
      {
        nativeBuildInputs = [ pkgs.coreutils ];
      }
      ''
        mkdir -p "$out/bin" "$out/themes" "$out/libexec"

        ${lib.concatStrings (
          lib.mapAttrsToList (name: drv: ''
            cp -r ${drv} "$out/themes/"${lib.escapeShellArg name}
          '') themeDrvs
        )}

        install -m755 ${htScript} "$out/bin/ht"
        ln -s ht "$out/bin/ht-set"
        ln -s ht "$out/bin/ht-reload"
        ln -s ht "$out/bin/ht-list"

        install -Dm644 ${./completions/_ht} "$out/share/zsh/site-functions/_ht"
        install -Dm644 ${./completions/ht.bash} "$out/share/bash-completion/completions/ht"

        ${lib.concatStrings (lib.mapAttrsToList hookInstall targets)}
      '';

  allPackages = [
    ht
  ]
  ++ lib.optional (cfg.iconTheme.package != null) cfg.iconTheme.package
  ++ lib.optional (cfg.cursorTheme.package != null) cfg.cursorTheme.package
  ++ lib.concatLists (lib.mapAttrsToList (_: target: target.packages) targets);
in
{
  imports = [
    ./options.nix
  ]
  ++ lib.mapAttrsToList (name: _: ./targets + "/${name}") (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./targets)
  );

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        packages = allPackages;
      }

      # Hyprland reloads its config when this file changes. The store path is
      # part of the file so a rebuilt ht also changes the file, and
      # config.reloaded in autostart.lua asks ht to reapply.
      (lib.mkIf (targets ? hyprland) {
        files.".config/hypr/hyprland.lua".text = lib.mkAfter ''
          -- ht: ${ht}
        '';
      })
    ]
  );
}
