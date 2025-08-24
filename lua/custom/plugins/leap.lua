return {
  {
    'ggandor/leap.nvim',
    event = 'VeryLazy',
    opts = {},

    init = function()
      -- Default Leap mappings (change to add_default_mappings() if you prefer)
      local leap = require 'leap'
      -- leap.create_default_mappings()

      -- Your explicit mappings
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward-to)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward-to)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)')

      -- Make Leap inclusive only when used with an operator (d/c/y/…).
      -- Implementation notes:
      -- - We flip opts.inclusive_motion on LeapEnter depending on the mode.
      -- - We always reset it on LeapLeave to avoid leaking state.
      local aug = vim.api.nvim_create_augroup('LeapInclusiveOps', { clear = true })
      local initial = nil

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LeapEnter',
        group = aug,
        callback = function()
          initial = require('leap').opts.inclusive_motion
          -- Detect operator-pending mode robustly:
          -- 'o' is pure operator-pending; 'no'/'nov' etc. appear during mapped ops.
          local mode = vim.api.nvim_get_mode().mode
          local in_op = (mode == 'o') or mode:match '^no'
          require('leap').opts.inclusive_motion = in_op and true or false
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'LeapLeave',
        group = aug,
        callback = function()
          require('leap').opts.inclusive_motion = initial
        end,
      })
    end,
  },
}
