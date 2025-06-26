local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local M = {}

local snippets = {
  -- odoo xpath
  s('copyright', {
    t {
      '//',
      '// Copyright (c) ',
    },
    t(os.date '%Y'),
    t {
      ' WEINZIERL ENGINEERING GmbH',
      '// All rights reserved.',
      '//',
      '// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR',
      '// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,',
      '// FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT',
      '// SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY,',
      '// WHETHER IN CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION',
      '// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE',
      '//',
    }, -- linebreak
  }),
  s('ponce', {
    t '#pragma once',
  }),
  s('nolint', {
    t '// NOLINT',
  }),
  s('todo', {
    t '// TODO: (mschaetz) ',
  }),
}

function M.load()
  ls.add_snippets('cpp', snippets)
  ls.add_snippets('c', snippets)
end

return M
