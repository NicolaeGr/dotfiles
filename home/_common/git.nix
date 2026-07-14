{ pkgs, ... }:
let
  gitIni = pkgs.formats.gitIni { listsAsDuplicateKeys = true; };
in
{
  rum.programs.git = {
    enable = true;
    package = pkgs.gitFull;

    settings = {
      log.showSignature = true;
      init.defaultBranch = "main";
      pull.rebase = true;

      safe.directory = [
        "/shared/*"
        "/storage/*"
      ];

      "includeIf \"gitdir:~/Projects/\"".path = "projects.inc";
    };

    ignore = ''
      .csvignore
      .direnv
      result
    '';
  };

  xdg.config.files."git/projects.inc".source = gitIni.generate "git-projects-inc" {
    url = {
      "ssh://git@github.com".insteadOf = "https://github.com";
      "ssh://git@gitlab.com".insteadOf = "https://gitlab.com";
    };
  };
}
