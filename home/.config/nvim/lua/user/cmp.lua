local cmp_ok, cmp = pcall(require, "cmp")
if not cmp_ok then
	vim.notify("cmp not found, make sure it is installed.")
	return
end

local luasnip_ok, luasnip = pcall(require, "luasnip")
if not luasnip_ok then
	vim.notify("luasnip not found, make sure it is installed.")
	return
end

require("luasnip/loaders/from_vscode").lazy_load()

local kind_icons = {
	Text = "",
	Method = "m",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

local tab_next = function(fallback)
	if cmp.visible() then
		cmp.select_next_item()
	elseif luasnip.expandable() then
		luasnip.expand()
	elseif luasnip.expand_or_jumpable() then
		luasnip.expand_or_jump()
	else
		fallback()
	end
end

local tab_prev = function(fallback)
	if cmp.visible() then
		cmp.select_prev_item()
	elseif luasnip.jumpable(-1) then
		luasnip.jump(-1)
	else
		fallback()
	end
end

local expand = function(args)
	luasnip.lsp_expand(args.body)
end

local format = function(entry, vim_item)
	vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
	vim_item.menu = ({
		nvim_lsp = "[Lsp]",
		luasnip = "[Snippet]",
		buffer = "[Buffer]",
		path = "[Path]",
	})[entry.source.name]

	return vim_item
end

cmp.setup({
	snippet = {
		expand = expand,
	},

	mapping = {
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-y>"] = cmp.config.disable,
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(tab_next, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(tab_prev, { "i", "s" }),
	},

	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = format,
	},

	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "path" },
	},

	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},
})
