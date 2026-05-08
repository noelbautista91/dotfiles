{ config, lib, pkgs, ... }:

{
  programs.neovim.enable = false;

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    imports = [
      ./nixvim-plugins/lsp.nix
      ./nixvim-plugins/completion.nix
      ./nixvim-plugins/ui.nix
      ./nixvim-plugins/git.nix
      ./nixvim-plugins/editing.nix
      ./nixvim-plugins/telescope.nix
      ./nixvim-plugins/dap.nix
    ];

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      termguicolors = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      clipboard = "unnamedplus";
      undolevels = 10000;
      scrolloff = 8;
      sidescrolloff = 8;
      cursorline = true;
      ignorecase = true;
      smartcase = true;
      wildmode = "longest:full,full";
      completeopt = "menu,menuone,noselect";
      confirm = true;
    };

    extraConfigLua = ''
      vim.cmd([[
        cnoreabbrev <expr> q ((getcmdtype() ==# ':' && getcmdline() ==# 'q') ? 'qa' : 'q')
        cnoreabbrev <expr> q! ((getcmdtype() ==# ':' && getcmdline() ==# 'q!') ? 'qa!' : 'q!')
      ]])
    '';

    keymaps = [
      {
        mode = "n";
        key = "<C-h>";
        action = "<Cmd>BufferLineCyclePrev<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<Cmd>BufferLineCycleNext<CR>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<C-/>";
        action = "<Cmd>ToggleTerm<CR>";
        options.desc = "Toggle terminal";
      }
      {
        mode = "n";
        key = "<leader>e";
        action.__raw = ''
          function()
            if vim.bo.filetype == "neo-tree" then
              vim.cmd("wincmd p")
            else
              vim.cmd("Neotree reveal")
            end
          end
        '';
        options.desc = "Toggle focus between file explorer and editor";
      }
      {
        mode = "n";
        key = "<leader>x";
        action.__raw = ''
          function()
            local cur = vim.api.nvim_get_current_buf()
            local bufs = vim.api.nvim_list_bufs()
            local real_bufs = vim.tbl_filter(function(b)
              return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted
            end, bufs)
            if #real_bufs > 1 then
              vim.cmd("bprevious")
              vim.cmd("bdelete " .. cur)
            else
              vim.cmd("enew")
              vim.cmd("bdelete " .. cur)
            end
          end
        '';
        options.desc = "Smart close buffer";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action = "<Cmd>LazyGit<CR>";
        options.desc = "Open lazygit";
      }
    ];
  };
}