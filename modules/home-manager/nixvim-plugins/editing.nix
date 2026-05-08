{ config, lib, pkgs, ... }:

{
  plugins.treesitter = {
    enable = true;
    settings = {
      highlight.enable = true;
      indent.enable = true;
    };
    languageRegister = {
      go = [ "gomod" "gosum" ];
    };
  };
  plugins.treesitter.ensureInstalled = [
    "go"
    "nix"
    "typescript"
    "tsx"
    "python"
    "json"
    "html"
    "lua"
    "vim"
    "vimdoc"
    "markdown"
    "bash"
    "css"
    "javascript"
    "yaml"
  ];

  plugins.conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        go = [ "gofmt" ];
        nix = [ "nixfmt" ];
        python = [ "ruff_format" ];
        javascript = [ "prettierd" ];
        typescript = [ "prettierd" ];
        html = [ "prettierd" ];
        json = [ "prettierd" ];
        css = [ "prettierd" ];
        lua = [ "stylua" ];
      };
      format_on_save = {
        timeoutMs = 500;
        lspFallback = true;
      };
    };
  };

  plugins.comment.enable = true;

  plugins.nvim-surround.enable = true;

  plugins.nvim-autopairs.enable = true;
}