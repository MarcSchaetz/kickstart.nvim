-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- [[ Setting options ]]
vim.o.swapfile = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.foldmethod = 'marker'

-- [[ Keymaps ]]
-- Fast escape keymaps
vim.keymap.set('i', 'jk', '<Esc>', {})
vim.keymap.set('i', 'kj', '<Esc>', {})
-- Fast quit and write keymaps
vim.keymap.set('n', '<leader>q', ':q<CR>', { desc = 'Close Neovim' })
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Write current buffer' })
-- diagnostics
vim.keymap.set('n', '<leader>E', 'vim.diagnostic.open_float', { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>Q', 'vim.diagnostic.setloclist', { desc = 'Open diagnostic [Q]uickfix list' })

return {
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
  },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      -- disable netrw at the very start of your init.lua
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', {})
      vim.api.nvim_create_user_command('FFile', ':NvimTreeFindFileToggle<CR>', { desc = 'Open nvim-tree and focus the current file' })

      require('nvim-tree').setup {
        on_attach = function(bufnr)
          local api = require 'nvim-tree.api'

          local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- default mappings
          api.config.mappings.default_on_attach(bufnr)

          -- custom mappings
          vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts 'Close Parent')
          vim.keymap.set('n', 'l', api.node.open.edit, opts 'Open File or Dir')
          vim.keymap.set('n', '<C-t>', api.tree.change_root_to_node, opts 'Change root')
          vim.keymap.set('n', '?', api.tree.toggle_help, opts 'Help')
        end,
        actions = {
          open_file = {
            resize_window = true,
            quit_on_open = true,
          },
        },
        sort = {
          sorter = 'case_sensitive',
        },
        view = {
          width = {},
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
      }
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function(plugin, opts)
      local tt = require 'toggleterm'
      local Terminal = require('toggleterm.terminal').Terminal
      local lazygit = Terminal:new { cmd = 'lazygit', hidden = true, direction = 'float' }

      function Lazygit_toggle()
        lazygit:toggle()
      end

      if not tt then
        return
      end

      tt.setup {
        direction = 'float',
        open_mapping = [[<c-t>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        close_on_exit = true,
        shell = vim.o.shell,
      }

      vim.keymap.set('n', '<leader>gg', ':lua Lazygit_toggle()<cr>', { desc = 'Lazygit' })
    end,
  },
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = true,
  },
  {
    'artemave/workspace-diagnostics.nvim',
  },
  {
    'github/copilot.vim',
    -- add options here
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.keymap.set('i', '<C-e>', 'copilot#Accept("<CR>")', { expr = true, silent = true, script = true })
      vim.keymap.set('i', '<C-d>', 'copilot#Dismiss()', { expr = true, silent = true, script = true })
    end,
  },
  {
    {
      'CopilotC-Nvim/CopilotChat.nvim',
      dependencies = {
        { 'gptlang/lua-tiktoken' },
        { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
        { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
      },
      build = 'make tiktoken', -- Only on MacOS or Linux
      opts = {
        -- add a new prompt for the chat that creates a git commit message in conventional commit format for the staged files
        prompts = {
          Commit = {
            prompt = 'Generate a git commit message for the staged files. Use conventional commit format.',
            description = 'Generate a git commit message for the staged files',
            icon = '',
          },
        },

        -- See Configuration section for options
      },
      -- See Commands section for default commands if you want to lazy load on them
    },
  },
}
