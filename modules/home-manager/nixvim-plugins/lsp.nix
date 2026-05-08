{ config, lib, pkgs, ... }:

{
  plugins.lsp = {
    enable = true;
    servers = {
      gopls.enable = true;
      nil_ls.enable = true;
      ts_ls.enable = true;
      pyright.enable = true;
      ruff.enable = true;
      jsonls.enable = true;
      html.enable = true;
      lua_ls.enable = true;
    };
    keymaps = {
      diagnostic = {
        "<leader>qd" = "open_float";
        "]d" = "goto_next";
        "[d" = "goto_prev";
      };
      lspBuf = {
        gd = "definition";
        gI = "implementation";
        gr = "references";
        K = "hover";
        "<leader>ca" = "code_action";
        "<leader>rn" = "rename";
        "<leader>D" = "type_definition";
      };
    };
  };

  plugins.fidget.enable = true;

  plugins.trouble.enable = true;

  keymaps = [
    {
      mode = "n";
      key = "<leader>xx";
      action = "<Cmd>Trouble diagnostics toggle<CR>";
      options.desc = "Diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options.desc = "Buffer diagnostics (Trouble)";
    }
  ];
}