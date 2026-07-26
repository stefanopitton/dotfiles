local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("python", {
	s("docstring", {
		t({ '"""', "" }),
		i(1, "Summary line."),
		t({ "", "", "Parameters" }),
		t({ "", "----------", "" }),
		i(2, "param"),
		t(": "),
		i(3, "type"),
		t({ "", "    " }),
		i(4, "description"),
		t({ "", "", "Returns" }),
		t({ "", "-------", "" }),
		i(5, "out"),
		t(": "),
		i(6, "type"),
		t({ "", "    " }),
		i(7, "description"),
		t({ "", '"""' }),
	}),
})
