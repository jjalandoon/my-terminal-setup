-- Custom plugins for enhanced terminal experience
-- These plugins complement the base kickstart.nvim configuration

return {
  -- Smooth scrolling for better visual experience
  -- {
  --   'karb94/neoscroll.nvim',
  --   config = function()
  --     require('neoscroll').setup {
  --       mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
  --       hide_cursor = true,
  --       stop_eof = true,
  --       respect_scrolloff = false,
  --       cursor_scrolls_alone = true,
  --       easing_function = 'quadratic',
  --     }
  --   end,
  -- },

  -- Better quickfix/location list
  -- {
  --   'kevinhwang91/nvim-bqf',
  --   ft = 'qf',
  --   config = function()
  --     require('bqf').setup()
  --   end,
  -- },

  -- Toggle terminal
  -- {
  --   'akinsho/toggleterm.nvim',
  --   version = '*',
  --   config = function()
  --     require('toggleterm').setup {
  --       size = 20,
  --       open_mapping = [[<c-\>]],
  --       hide_numbers = true,
  --       shade_terminals = true,
  --       start_in_insert = true,
  --       insert_mappings = true,
  --       terminal_mappings = true,
  --       persist_size = true,
  --       direction = 'float',
  --       close_on_exit = true,
  --       shell = vim.o.shell,
  --       float_opts = {
  --         border = 'curved',
  --         winblend = 0,
  --       },
  --     }
  --   end,
  -- },

  -- Git integration with fugitive
  -- {
  --   'tpope/vim-fugitive',
  --   cmd = { 'Git', 'G', 'Gdiffsplit', 'Gread', 'Gwrite', 'Ggrep', 'GMove', 'GDelete', 'GBrowse', 'GRemove', 'GRename', 'Glgrep', 'Gedit' },
  --   ft = { 'fugitive' },
  -- },

  -- Better commenting
  -- {
  --   'numToStr/Comment.nvim',
  --   config = function()
  --     require('Comment').setup()
  --   end,
  -- },

  -- Auto-save
  -- {
  --   'okuuva/auto-save.nvim',
  --   cmd = 'ASToggle',
  --   event = { 'InsertLeave', 'TextChanged' },
  --   opts = {
  --     enabled = false, -- start auto-save when the plugin is loaded (i.e. on startup)
  --     trigger_events = { 'InsertLeave', 'TextChanged' },
  --     condition = function(buf)
  --       local fn = vim.fn
  --       local utils = require 'auto-save.utils.data'
  --
  --       -- don't save for special-buffers
  --       if fn.getbufvar(buf, '&modifiable') == 1 and utils.not_in(fn.getbufvar(buf, '&filetype'), {}) then
  --         return true
  --       end
  --       return false
  --     end,
  --     write_all_buffers = false,
  --     debounce_delay = 1000,
  --   },
  -- },

  -- Highlight colors
  -- {
  --   'NvChad/nvim-colorizer.lua',
  --   config = function()
  --     require('colorizer').setup {
  --       filetypes = { '*' },
  --       user_default_options = {
  --         RGB = true,
  --         RRGGBB = true,
  --         names = true,
  --         RRGGBBAA = true,
  --         AARRGGBB = false,
  --         rgb_fn = true,
  --         hsl_fn = true,
  --         css = true,
  --         css_fn = true,
  --         mode = 'background',
  --         tailwind = true,
  --       },
  --     }
  --   end,
  -- },

  -- Improved folding
  -- {
  --   'kevinhwang91/nvim-ufo',
  --   dependencies = {
  --     'kevinhwang91/promise-async',
  --   },
  --   config = function()
  --     vim.o.foldcolumn = '1'
  --     vim.o.foldlevel = 99
  --     vim.o.foldlevelstart = 99
  --     vim.o.foldenable = true
  --
  --     require('ufo').setup {
  --       provider_selector = function()
  --         return { 'treesitter', 'indent' }
  --       end,
  --     }
  --
  --     vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
  --     vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
  --   end,
  -- },

  -- Better marks
  -- {
  --   'chentoast/marks.nvim',
  --   config = function()
  --     require('marks').setup {
  --       default_mappings = true,
  --       builtin_marks = { '.', '<', '>', '^' },
  --       cyclic = true,
  --       force_write_shada = false,
  --       refresh_interval = 250,
  --       sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
  --     }
  --   end,
  -- },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup {
        indent = {
          char = '│',
          tab_char = '│',
        },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
        },
      }
    end,
  },

  -- Surround text objects
  -- {
  --   'kylechui/nvim-surround',
  --   version = '*',
  --   event = 'VeryLazy',
  --   config = function()
  --     require('nvim-surround').setup()
  --   end,
  -- },
}
