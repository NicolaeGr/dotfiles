{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  vimPlugins = final: prev: {
    vimPlugins = prev.vimPlugins // {
      fine-cmdline-nvim = prev.vimUtils.buildVimPlugin {
        name = "fine-cmdline.nvim";
        src = inputs.fine-cmdline-nvim;
      };
      cust_lualine-nvim = prev.vimUtils.buildVimPlugin {
        name = "lualine.nvim";
        src = inputs.lualine-nvim;
      };
    };
  };
}
