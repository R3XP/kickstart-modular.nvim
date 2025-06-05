--[[

  general keymaps that dont have a better place to live go here.

]]
--

vim.keymap.set('n', '-', '<cmd>Oil<CR>')

vim.keymap.set('n', '<C-q>', '<C-w>q', { desc = 'Close the current window' })

vim.keymap.set('n', '<leader>bs', '<cmd>w<CR>', { desc = '[S]ave contens of current [b]uffer' })

local function bind_cmd(binding, cmd, opts, modes)
  vim.keymap.set(modes or 'n', binding, '<cmd>' .. cmd .. '<CR>', opts)
end
-- Git keymmaps
bind_cmd('<leader>gg', 'Neogit', { desc = '[G]it [G]ud (open Neogit)' })
bind_cmd('<leader>gs', 'Gitsigns preview_hunk_inline', { desc = '[G]it [S]how hunk' })
bind_cmd('<leader>gS', 'Gitsigns preview_hunk', { desc = '[G]it [S]how hunk (popup)' })
bind_cmd('<leader>gn', 'Gitsigns next_hunk', { desc = '[G]it [N]ext Hunk' })
bind_cmd('<leader>gp', 'Gitsigns prev_hunk', { desc = '[G]it [P]revious Hunk' })
bind_cmd('<leader>gR', 'Gitsigns reset_hunk', { desc = '[G]it [R]eset Hunk' }, { 'n', 'v' })

vim.cmd [[autocmd FileType * set tabstop=4 shiftwidth=4]]

-- toggle keymaps
bind_cmd('<leader>tc', 'TSContextToggle', { desc = '[T]oggle [C]ontext' })
bind_cmd('<leader>tT', 'TailwindConcealToggle', { desc = '[T]oggle [T]ailwind' })

vim.keymap.set('n', '<leader>tl', function()
  vim.opt.list = not vim.opt.list:get()
end, { desc = '[T]oggle [L]ist chars' })

local show_diagnostic_text = true
vim.keymap.set('n', '<leader>td', function()
  show_diagnostic_text = not show_diagnostic_text
  vim.diagnostic.config { virtual_text = show_diagnostic_text }
end, { desc = '[T]oggle [L]ist chars' })

vim.keymap.set('n', '<leader>tt', function()
  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
end, { desc = '[T]oggle [T]abs' })

return {}
