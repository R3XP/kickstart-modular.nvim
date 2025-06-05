return {
  {
    'ggandor/leap.nvim',
    opts = {},
    init = function()
      require('leap').create_default_mappings()
    end,
  },
}
