{ config, lib, pkgs, ... }:

{
  plugins.telescope = {
    enable = true;
    extensions = {
      fzf-native = {
        enable = true;
        settings = {
          fuzzy = true;
          override_generic_sorter = true;
          override_file_sorter = true;
        };
      };
    };
    settings = {
      defaults = {
        file_ignore_patterns = [
          "node_modules"
          ".git/"
          "dist/"
          "build/"
        ];
        layout_config = {
          horizontal = {
            prompt_position = "top";
            preview_width = 0.55;
          };
        };
        sorting_strategy = "ascending";
      };
    };
    keymaps = {
      "<leader>sf" = {
        action = "find_files";
        options.desc = "Find files";
      };
      "<leader>sg" = {
        action = "live_grep";
        options.desc = "Live grep";
      };
      "<leader>sb" = {
        action = "buffers";
        options.desc = "Find buffers";
      };
      "<leader>fr" = {
        action = "oldfiles";
        options.desc = "Recent files";
      };
      "<leader>sk" = {
        action = "keymaps";
        options.desc = "Find keymaps";
      };
      "<leader>sd" = {
        action = "diagnostics";
        options.desc = "Find diagnostics";
      };
      "<leader>ss" = {
        action = "lsp_document_symbols";
        options.desc = "Document symbols";
      };
      "<leader>sS" = {
        action = "lsp_workspace_symbols";
        options.desc = "Workspace symbols";
      };
    };
  };
}