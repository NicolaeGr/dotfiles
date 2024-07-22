{ options, config, lib, ... }: {
  options = {
    git.enable = lib.mkEnableOption {
      default = true;
      description = "Enable git integration";
    };
  };

  config = lib.mkIf config.git.enable {
    programs.git = {
      enable = true;

      includes = [
        {
          condition = "gitdir:~/Projects/work/";

          contents = {
            user = {
              name = "GrNicolae";
              email = "170510723+GrNicolae@users.noreply.github.com";
            };
          };
        }
        {
          contents = {
            init.defaultBranch = "main";
            push = {
              default = "current";
              autoSetupRemote = true;
            };
          };
        }
      ];

      userName = "NicolaeGr";
      userEmail = "114419701+NicolaeGr@users.noreply.github.com";
    };
  };
}
