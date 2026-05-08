{ config, lib, pkgs, ... }:

{
  plugins.gitsigns = {
    enable = true;
    settings = {
      signs = {
        add = { text = "+"; };
        change = { text = "~"; };
        delete = { text = "_"; };
        topdelete = { text = "‾"; };
        changedelete = { text = "~"; };
      };
      current_line_blame = true;
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "]h";
      action.__raw = "function() require('gitsigns').nav_hunk('next') end";
      options.desc = "Next git hunk";
    }
    {
      mode = "n";
      key = "[h";
      action.__raw = "function() require('gitsigns').nav_hunk('prev') end";
      options.desc = "Previous git hunk";
    }
    {
      mode = "n";
      key = "<leader>hs";
      action.__raw = "function() require('gitsigns').stage_hunk() end";
      options.desc = "Stage hunk";
    }
    {
      mode = "n";
      key = "<leader>hr";
      action.__raw = "function() require('gitsigns').reset_hunk() end";
      options.desc = "Reset hunk";
    }
    {
      mode = "n";
      key = "<leader>hp";
      action.__raw = "function() require('gitsigns').preview_hunk() end";
      options.desc = "Preview hunk";
    }
    {
      mode = "n";
      key = "<leader>hb";
      action.__raw = "function() require('gitsigns').blame_line() end";
      options.desc = "Blame line";
    }
  ];

  plugins.lazygit.enable = true;
}