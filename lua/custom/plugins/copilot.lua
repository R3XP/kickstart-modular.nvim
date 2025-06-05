vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuOpen',
  callback = function()
    vim.cmd 'Copilot disable'
    vim.b.copilot_blink_disabled = true
    vim.b.copilot_enabled = true
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'BlinkCmpMenuClose',
  callback = function()
    if vim.b.copilot_blink_disabled then
      vim.cmd 'Copilot enable'
    end
    vim.b.copilot_enabled = false
  end,
})

return {
  {
    'github/copilot.vim',
    conf = function()
      vim.keymap.set('i', '<C-y>', 'copilot#Accept("")', {
        expr = true,
        replace_keycodes = false,
      })
      vim.g.copilot_no_tab_map = true
    end,
  },
}
