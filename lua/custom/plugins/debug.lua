return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<leader>dc',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<leader>ds',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<leader>dS',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<leader>dx',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<leader>dr',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
    {
      '<leader>de',
      function()
        require('dapui').eval()
      end,
      desc = 'Debug: evaluate',
    },

    -- .NET convenience
    {
      '<leader>da',
      function()
        -- Attach: opens a process picker
        local dap = require 'dap'
        local cfgs = require('dap').configurations.cs or {}
        -- find an attach config by name or build one on the fly
        local attach = nil
        for _, c in ipairs(cfgs) do
          if c.request == 'attach' then
            attach = c
            break
          end
        end
        if attach then
          dap.run(attach)
        else
          dap.run {
            type = 'coreclr',
            request = 'attach',
            processId = require('dap.utils').pick_process,
            justMyCode = false,
          }
        end
      end,
      desc = 'Debug: Attach to .NET process',
    },
    {
      '<leader>dQ',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug: Terminate',
    },
    {
      '<leader>dR',
      function()
        require('dap').run_last()
      end,
      desc = 'Debug: Run last',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with reasonable defaults
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      handlers = {},

      -- Ensure the adapters you want are present
      ensure_installed = {
        -- add more as needed
        'netcoredbg', -- <-- .NET Core CLR debugger
        -- 'delve',     -- example for Go (already handled by nvim-dap-go)
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    ---------------------------------------------------------------------
    --                        .NET (C#/F#) DAP                         --
    ---------------------------------------------------------------------

    -- Try to locate netcoredbg from Mason first, then fall back to system PATH.
    local function find_netcoredbg()
      local mason = vim.fn.stdpath 'data' .. '/mason/packages/netcoredbg'
      local exe = mason .. '/netcoredbg/netcoredbg'
      if vim.loop.os_uname().version:match 'Windows' then
        exe = mason .. '\\netcoredbg\\netcoredbg.exe'
      end
      if vim.fn.executable(exe) == 1 then
        return exe
      end
      if vim.fn.executable 'netcoredbg' == 1 then
        return 'netcoredbg'
      end
      return nil
    end

    local netcoredbg = find_netcoredbg()
    if not netcoredbg then
      vim.notify('netcoredbg not found. Install via :MasonInstall netcoredbg or your OS package manager.', vim.log.levels.ERROR)
    end

    -- CoreCLR adapter using netcoredbg (VS Code interpreter)
    dap.adapters.coreclr = {
      type = 'executable',
      command = netcoredbg,
      args = { '--interpreter=vscode' },
    }

    -- Heuristic to propose a default DLL to launch
    local function guess_debug_dll()
      -- Search bin/Debug/** for a non-testhost DLL
      local cwd = vim.fn.getcwd()
      local matches = vim.fn.globpath(cwd, 'bin/Debug/**/*.dll', false, true)
      for _, p in ipairs(matches) do
        local name = p:match '([^/\\]+)$' or ''
        if not name:match 'testhost%.dll' and not name:match 'vstest%.execution%.engine' then
          return p
        end
      end
      -- Fallback to a common TFM path template; user can edit in prompt
      return cwd .. '/bin/Debug/net8.0/YourApp.dll'
    end

    -- Shared configs for C# and F#
    local coreclr_launch_console = {
      name = 'Launch (.NET console)',
      type = 'coreclr',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to dll: ', guess_debug_dll(), 'file')
      end,
      cwd = '${workspaceFolder}',
      stopAtEntry = false,
      console = 'integratedTerminal',
      justMyCode = true,
    }

    local coreclr_launch_web = {
      name = 'Launch (ASP.NET Core)',
      type = 'coreclr',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to web dll: ', guess_debug_dll(), 'file')
      end,
      cwd = '${workspaceFolder}',
      stopAtEntry = false,
      env = {
        ASPNETCORE_ENVIRONMENT = 'Development',
        ASPNETCORE_URLS = 'http://localhost:5000',
      },
      console = 'integratedTerminal',
      justMyCode = true,
    }

    local coreclr_attach = {
      name = 'Attach (pick .NET process)',
      type = 'coreclr',
      request = 'attach',
      processId = require('dap.utils').pick_process,
      justMyCode = false,
    }

    dap.configurations.cs = { coreclr_launch_console, coreclr_launch_web, coreclr_attach }
    dap.configurations.fs = { coreclr_launch_console, coreclr_launch_web, coreclr_attach }
    -- If you also use VB.NET:
    -- dap.configurations.vb = { coreclr_launch_console, coreclr_launch_web, coreclr_attach }

    -- Optional: build before launch (maps to <leader>dbu below if you want a key)
    local function dotnet_build_debug()
      vim.fn.jobstart({ 'dotnet', 'build', '-c', 'Debug' }, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_exit = function(_, code)
          if code ~= 0 then
            vim.notify('dotnet build failed (Debug).', vim.log.levels.ERROR)
          else
            vim.notify('dotnet build succeeded (Debug).', vim.log.levels.INFO)
          end
        end,
      })
    end
    vim.keymap.set('n', '<leader>dbu', dotnet_build_debug, { desc = 'dotnet build (Debug)' })
  end,
}
