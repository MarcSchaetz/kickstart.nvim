-- Description: This file initializes the Neovim configuration and sets up plugins.
-- Author: Marc Schätz
-- Date: 2025-07-30

-- ==================
-- [[ Basic Setup ]]
-- ==================

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.swapfile = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Undercurl
vim.cmd [[let &t_Cs = "\e[4:3m"]]
vim.cmd [[let &t_Ce = "\e[4:0m"]]

-- ========================================
-- [[ Install `lazy.nvim` plugin manager ]]
-- ========================================

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- =============
-- [[ Plugins ]]
-- =============

require('lazy').setup {
  { 'folke/which-key.nvim', event = 'VimEnter' },
  {
    'ibhagwan/fzf-lua',
    config = function()
      local fzf = require 'fzf-lua'
      fzf.setup {
        keymap = {
          fzf = {
            ['ctrl-w'] = 'select-all+accept',
          },
        },
        winopts = {
          preview = {
            layout = 'vertical',
          },
        },
        files = {
          follow = true,
          fd_opts = '--type f --hidden --follow --exclude .git',
        },
      }

      fzf.register_ui_select(function(_, items)
        local min_h, max_h = 0.15, 0.70
        local h = (#items + 4) / vim.o.lines
        if h < min_h then
          h = min_h
        elseif h > max_h then
          h = max_h
        end
        return { winopts = { height = h, width = 0.60, row = 0.40 } }
      end)

      vim.keymap.set('n', '<leader>/', fzf.lgrep_curbuf, { desc = 'Search current File' })
      vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', fzf.grep, { desc = '[Search] with [G]rep' })
      vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = 'Builtin' })
      vim.keymap.set('n', '<leader>so', fzf.oldfiles, { desc = '[S]earch [O]ld Files' })
      vim.keymap.set('n', '<leader>se', fzf.lsp_workspace_diagnostics, { desc = '[S]earch [E]rrors' })
      vim.keymap.set('n', '<leader><leader>', '<cmd>FzfLua buffers<CR>', { desc = 'Search open Buffers' })
      vim.keymap.set('n', '<leader>sn', function()
        require('fzf-lua').files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      vim.keymap.set('n', 'grr', fzf.lsp_references, { desc = 'LSP [R]eferences' })
      vim.keymap.set('n', 'grt', fzf.lsp_typedefs, { desc = 'LSP [T]ype definitions' })
      vim.keymap.set('n', 'gri', fzf.lsp_implementations, { desc = 'LSP [I]mplementations' })
      vim.keymap.set('n', 'gO', fzf.lsp_document_symbols, { desc = 'LSP Document Symb[o]ls' })

      local actions = fzf.actions
      actions = {
        files = {
          ['crtl-h'] = actions.toggle_hidden,
        },
      }
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {},
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = { enable = true, disable = {} },
    },
  },
  {
    'github/copilot.vim',
    -- add options here
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.keymap.set('i', '<C-e>', 'copilot#Accept("<CR>")', { expr = true, silent = true, script = true })
      vim.keymap.set('i', '<C-d>', 'copilot#Dismiss()', { expr = true, silent = true, script = true })
      vim.keymap.set('i', '<C-L>', '<Plug>(copilot-accept-word)')
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
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      -- 'nvim-tree/nvim-web-devicons',
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
  { 'mason-org/mason.nvim', opts = {} },
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
              require('custom.snippets.cpp').load()
              require('custom.snippets.xml').load()
            end,
          },
        },
        opts = {},
      },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'enter',
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },
      appearance = {
        nerd_font_variant = 'mono',
      },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets' },
        providers = {
          snippets = {
            min_keyword_length = 2, -- Minimum keyword length to trigger snippet completion
          },
          -- lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      require('mini.statusline').setup { use_icons = vim.g.have_nerd_font }
      require('mini.diff').setup {
        view = {
          style = 'sign',
          signs = {
            add = '▎',
            change = '▎',
            delete = '',
          },
        },
      }
    end,
  },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false, keywords = {
      TODO = { alt = { 'ToDo' } },
    }, highlight = {
      pattern = [[.*<(KEYWORDS)\s*:?]],
    } },
  },
  { 'neovim/nvim-lspconfig' },
  { 'stevearc/dressing.nvim' },
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        lua = { 'stylua' },
        typescript = { 'prettier' },
        javascript = { 'prettier' },
        html = { 'prettier' },
        css = { 'prettier' },
        json = { 'prettier' },
        python = { 'black' },
      },
    },
  },
  {
    -- colorscheme
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
}
-- ============================
-- [[ Load Additonal Plugins ]]
-- ============================

require 'kickstart.plugins.debug'

-- =============
-- [[ Keymaps ]]
-- =============

vim.keymap.set('i', 'jk', '<Esc>', { silent = true, noremap = true })
vim.keymap.set('i', 'kj', '<Esc>', { silent = true, noremap = true })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', '<cmd>quit<CR>', { desc = 'Quit Neovim' })
vim.keymap.set('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>E', vim.diagnostic.open_float, { desc = 'Show diagnostic Error messages' })
vim.keymap.set('n', '<leader>Q', vim.diagnostic.setloclist, { desc = 'Open diagnostic Quickfix list' })

-- ========================
-- [[ Basic Autocommands ]]
-- ========================

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- =======================
-- [[ LSP Configuration ]]
-- =======================

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', { clear = true }),
  callback = function(event)
    local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = 'Go to [d]efinition',
    })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {
      buffer = event.buf,
      desc = '[G]o to [D]eclaration',
    })

    vim.keymap.set('n', '<leader>f', function()
      require('conform').format { async = true }
    end, {
      buffer = event.buf,
      desc = 'Format current buffer',
    })

    if client:supports_method 'textDocument/formatting' then
      -- Set up keymap for formatting
    end
  end,
})

local capabilities = {
  textDocument = {
    semanticTokens = {
      multilineTokenSupport = true,
    },
  },
}

capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

vim.lsp.config('*', {
  capabilities = capabilities,
  root_markers = { '.git' },
})

vim.lsp.config('jdtls', {
  capabilities = capabilities,
  root_markers = { '.git', 'mvnw', 'gradlew' },
  cmd = { '/home/marc/jdtls/bin/jdtls' }, -- Adjust the command if necessary
})

vim.lsp.enable 'ts_ls'
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'clangd'
vim.lsp.enable 'angularls'
vim.lsp.enable 'pyright'
vim.lsp.enable 'jedi_language_server'
vim.lsp.enable 'tailwindcss'
-- vim.lsp.enable 'jdtls'
vim.lsp.enable 'emmet-ls'

vim.treesitter.language.add('mustache', {
  path = '/home/marc/workspace/tree-sitter-mustache/mustache.so',
})
vim.treesitter.language.register('mustache', { 'mustache' })

-- ==============================
-- [[ Diagnostic Configuration ]]
-- ==============================

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded' },
  virtual_text = {
    severity = {
      max = vim.diagnostic.severity.INFO,
    },
  },
  virtual_lines = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
    prefix = ' ',
    spacing = 2,
  },
}

vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = '#db4b4b' })

vim.keymap.set('n', 'gld', function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config { virtual_lines = new_config }
end, { desc = 'Toggle diagnostic virtual_lines' })

-- ============================
-- [[ Angular File Selection ]]
-- ============================

local select_angular_file = function()
  -- get the current file path of the active buffer
  local current_file = vim.api.nvim_buf_get_name(0)
  -- get the directory of the current file
  local current_dir = vim.fn.fnamemodify(current_file, ':p:h')
  -- strip extension from the current file path
  current_file = vim.fn.fnamemodify(current_file, ':p:r:t')
  -- if current_file ends on .spec.ts, remove the .spec part
  if current_file:match '%.spec$' then
    current_file = current_file:sub(1, -6) -- remove the last 5 characters (.spec)
  end

  local files = vim.fn.globpath(current_dir, vim.fn.fnamemodify(current_file, ':t') .. '.*', false, true)
  -- select one of the files via vim.ui.select
  vim.ui.select(files, {
    prompt = 'Select an Angular file:',
    format_item = function(item)
      return vim.fn.fnamemodify(item, ':t') -- display only the file name
    end,
  }, function(selected_file)
    -- search if there is already a buffer with the selected file
    local bufnr = vim.fn.bufnr(selected_file)
    if bufnr == -1 then
      -- if not, open the file in a new buffer
      vim.cmd('edit ' .. selected_file)
    else
      -- if yes, switch to the existing buffer
      vim.cmd('buffer ' .. bufnr)
    end
  end)
end

vim.keymap.set('n', '<leader>sa', select_angular_file, { desc = 'Select Angular file' })
