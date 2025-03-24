return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      
      -- Add keymaps
      vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Breakpoint Condition" })
      vim.keymap.set("n", "<leader>db", function() dap.toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", function() dap.continue() end, { desc = "Run/Continue" })
      vim.keymap.set("n", "<leader>dC", function() dap.run_to_cursor() end, { desc = "Run to Cursor" })
      vim.keymap.set("n", "<leader>di", function() dap.step_into() end, { desc = "Step Into" })
      vim.keymap.set("n", "<leader>do", function() dap.step_out() end, { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dO", function() dap.step_over() end, { desc = "Step Over" })
      vim.keymap.set("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "Toggle REPL" })
      vim.keymap.set("n", "<leader>dt", function() dap.terminate() end, { desc = "Terminate" })
      
      -- R language debugging configuration
      -- First, you need to install dgkf/debugadapter from GitHub:
      -- remotes::install_github("dgkf/debugadapter")
      dap.adapters.r = function(callback, config)
          callback({
              type = "server",
              host = config.host or "127.0.0.1",
              port = config.port or 18721,
              executable = {
                  command = "R",
                  args = {
                      "--slave",
                      "-e",
                      "debugadapter::serve(port=" .. (config.port or 18721) .. ")"
                  }
              }
          })
      end
      
      dap.configurations.r = {
          {
              type = "r",
              request = "launch",
              name = "Launch R File",
              file = "${file}",
              args = {},
              debugMode = "file",
              workingDirectory = "${workspaceFolder}",
              overrides = function(conf)
                  conf.args = {
                      -- Additional arguments to pass to the R script
                  }
                  return conf
              end
          },
          {
              type = "r",
              request = "attach",
              name = "Attach to R process",
              debugMode = "function",
              host = "127.0.0.1",
              port = 18721
          }
      }
      
      -- Setup signs
      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticSignError', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticSignWarn', linehl = 'CursorLine', numhl = '' })
      vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DiagnosticSignHint', linehl = '', numhl = '' })
      vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticSignWarn', linehl = '', numhl = '' })
      vim.fn.sign_define('DapLogPoint', { text = '◉', texthl = 'DiagnosticSignInfo', linehl = '', numhl = '' })
    end,
  },
  
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 10,
          position = "bottom",
        },
      },
    },
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      
      dapui.setup(opts)
      
      -- Auto open/close dapui
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },
  
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = false,
      all_frames = false,
      virt_text_pos = 'eol',
    },
  },
  
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "mason.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    opts = {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        -- Debuggers to auto-install
      }
    },
  },
  
  {
    "jbyuki/one-small-step-for-vimkind",
    config = function()
      local dap = require("dap")
      dap.adapters.nlua = function(callback, conf)
        local adapter = {
          type = "server",
          host = conf.host or "127.0.0.1",
          port = conf.port or 8086,
        }
        if conf.start_neovim then
          local dap_run = dap.run
          dap.run = function(c)
            adapter.port = c.port
            adapter.host = c.host
          end
          require("osv").run_this()
          dap.run = dap_run
        end
        callback(adapter)
      end
      dap.configurations.lua = {
        {
          type = "nlua",
          request = "attach",
          name = "Run this file",
          start_neovim = {},
        },
        {
          type = "nlua",
          request = "attach",
          name = "Attach to running Neovim instance (port = 8086)",
          port = 8086,
        },
      }
    end,
  },
}
