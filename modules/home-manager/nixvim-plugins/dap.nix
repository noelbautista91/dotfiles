{ config, lib, pkgs, ... }:

{
  plugins.dap.enable = true;

  plugins.dap-go = {
    enable = true;
    delve.path.__raw = ''"${pkgs.delve}/bin/dlv"'';
  };

  plugins.dap-python.enable = true;

  plugins.dap-ui = {
    enable = true;
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>db";
      action.__raw = "function() require('dap').toggle_breakpoint() end";
      options.desc = "Toggle breakpoint";
    }
    {
      mode = "n";
      key = "<leader>dc";
      action.__raw = "function() require('dap').continue() end";
      options.desc = "Start/continue debug";
    }
    {
      mode = "n";
      key = "<leader>di";
      action.__raw = "function() require('dap').step_into() end";
      options.desc = "Step into";
    }
    {
      mode = "n";
      key = "<leader>dO";
      action.__raw = "function() require('dap').step_over() end";
      options.desc = "Step over";
    }
    {
      mode = "n";
      key = "<leader>do";
      action.__raw = "function() require('dap').step_out() end";
      options.desc = "Step out";
    }
    {
      mode = "n";
      key = "<leader>du";
      action.__raw = "function() require('dapui').toggle() end";
      options.desc = "Toggle DAP UI";
    }
    {
      mode = "n";
      key = "<leader>dR";
      action.__raw = "function() require('dap').repl.toggle() end";
      options.desc = "Toggle REPL";
    }
  ];

  extraConfigLua = ''
    local dap, dapui = require("dap"), require("dapui")
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  '';
}