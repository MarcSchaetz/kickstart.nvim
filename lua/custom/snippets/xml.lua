local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

local M = {}

local snippets = {
	-- odoo xpath
	s("oxp", {
		t("<xpath expr=\""),
		i(1),
		t("\" position=\"\">"),
		t({ "", "" }), -- linebreak
		t("</xpath>")
	}),
	-- odoo record
	s("orecord", {
		t("<record id=\""),
		i(1),
		t("\" model=\""),
		i(2, "ir.ui.view"),
		t("\">"),
		t({ "", "" }),
		t("</record>")
	}),
	-- odoo field
	s("ofield", {
	t("<field name=\""),
	i(1),
	t("\"/>")
	}),
	-- odoo field long
	s("ofieldlong", {
	t("<field name=\""),
	i(1),
	t("\">"),
	t("</field>")
	})
}


function M.load()
	ls.add_snippets("xml", snippets)
end

return M
