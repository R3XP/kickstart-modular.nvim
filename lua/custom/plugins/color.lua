return {
  {
    'sho-87/kanagawa-paper.nvim',
  },
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,

    config = function()
      vim.cmd.colorscheme 'kanagawa'
    end,
  },
}
