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
}
