{ config, lib, pkgs, ... }:

{
  plugins.luasnip = {
    enable = true;
    settings = {
      history = true;
      update_events = "TextChanged,TextChangedI";
    };
  };

  plugins.friendly-snippets.enable = true;

  plugins.cmp = {
    enable = true;
    settings = {
      snippet.expand = "luasnip";
      mapping = {
        "<C-Space>" = "cmp.mapping.complete()";
        "<C-n>" = "cmp.mapping.select_next_item()";
        "<C-p>" = "cmp.mapping.select_prev_item()";
        "<C-e>" = "cmp.mapping.abort()";
        "<CR>" = "cmp.mapping.confirm({ select = true })";
        "<Tab>" = ''
          cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" })
        '';
        "<S-Tab>" = ''
          cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" })
        '';
      };
      sources = [
        { name = "nvim_lsp"; }
        { name = "luasnip"; }
        { name = "buffer"; }
        { name = "path"; }
      ];
    };
  };

  plugins.cmp-nvim-lsp.enable = true;
  plugins.cmp-buffer.enable = true;
  plugins.cmp-path.enable = true;
  plugins.cmp-cmdline = {
    enable = true;
    settings = {
      sources = [
        { name = "path"; }
        { name = "cmdline"; }
      ];
    };
  };
}