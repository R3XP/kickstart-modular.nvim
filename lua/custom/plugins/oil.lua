return {
  {
    'stevearc/oil.nvim',
    opts = {
      keymaps = {
        ['Y'] = 'actions.yank_entry',
      },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if prefer nvim-web-devicons
  },
  {
    'albenisolmos/telescope-oil.nvim',
    dependencies = {
      {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
      },
    },
    config = function()
      require('telescope').load_extension 'oil'

      vim.keymap.set('n', '<leader>sF', '<cmd>Telescope oil<cr>', {
        desc = '[F]olders',
      })
    end,
  },
}
