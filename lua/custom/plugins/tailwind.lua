return {
  'luckasRanarison/tailwind-tools.nvim',
  name = 'tailwind-tools',
  build = ':UpdateRemotePlugins',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim', -- optional
    'neovim/nvim-lspconfig',
  },
  -- @type TailwindTools.Option
  opts = {

    filetypes = { 'rust', 'html' },
    server = {
      filetypes = { 'rust', 'html' },
      init_options = { userLanguages = { rust = 'html' } },
      override = true, -- übernimmt das Setup für tailwindcss-language-server

      settings = {

        includeLanguages = {
          eelixir = 'html-eex',
          eruby = 'erb',
          htmlangular = 'html',
          templ = 'html',
          rust = 'html',
        },
        -- includeLanguages = {
        --   rust = 'html',
        -- },
        experimental = {
          classRegex = {
            -- { 'class:\\s*"([^"]*)"' },
            { 'class: "(.*)"' },
          },
        },
      },
    },
  },
}

-- tailwindcss = {
--           settings = {
--             tailwindCSS = {
--               experimental = {
--                 classRegex = {
--                   -- Matches: class: "w-16 bg-red-500"
--                   { 'class: "(.*)"' },
--                 },
--               },
--             },
--           },
--           filetypes = {
--             'html',
--             'css',
--             'scss',
--             'javascript',
--             'javascriptreact',
--             'typescript',
--             'typescriptreact',
--             'svelte',
--             'rust', -- wichtig!
--           },
--           init_options = {
--             userLanguages = {
--               rust = 'html', -- sagt dem Server, dass Rust wie HTML behandelt werden soll
--             },
--           },
--         }
