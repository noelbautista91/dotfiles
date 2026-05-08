{ config, lib, pkgs, ... }:

{
  colorschemes.catppuccin = {
    enable = true;
    settings.flavour = "mocha";
  };

  plugins.lualine = {
    enable = true;
    settings = {
      sections = {
        lualine_a = [ "mode" ];
        lualine_b = [ "branch" "diff" "diagnostics" ];
        lualine_c = [ "filename" ];
        lualine_x = [ "encoding" "fileformat" "filetype" ];
        lualine_y = [ "progress" ];
        lualine_z = [ "location" ];
      };
    };
  };

  plugins.bufferline.enable = true;

  plugins.neo-tree = {
    enable = true;
    settings = {
      window = {
        position = "left";
        width = 30;
      };
      filesystem.follow_current_file.enabled = true;
    };
  };

  extraConfigLua = ''
    vim.api.nvim_create_autocmd("VimEnter", {
      pattern = "*",
      callback = function()
        vim.defer_fn(function()
          vim.cmd("Neotree show")
        end, 50)
      end,
    })
  '';

  plugins.which-key.enable = true;

  plugins.indent-blankline.enable = true;

  plugins.web-devicons.enable = true;

  plugins.todo-comments.enable = true;

  plugins.mini.enable = true;
  plugins.mini.modules = {
    icons = { };
  };
}