return {
  {
    'mrcjkb/rustaceanvim',
    version = '^6', -- Recommended
    lazy = false, -- This plugin is already lazy
    init = function()
      -- Configure rustaceanvim before it loads
      vim.g.rustaceanvim = {
        server = {
          capabilities = function()
            -- Get the same capabilities as other LSPs
            local capabilities = require('blink.cmp').get_lsp_capabilities()
            return capabilities
          end,
        },
      }
    end,
  },
}
