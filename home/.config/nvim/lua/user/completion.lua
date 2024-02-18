local luasnip = require("luasnip")
local luasnip_loader = require("luasnip/loaders/from_vscode")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local cmp = require("cmp")
local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

local KIND_ICONS = {
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

local function tab_next(fallback)
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

local function tab_prev(fallback)
	if cmp.visible() then
		cmp.select_prev_item()
	elseif luasnip.jumpable(-1) then
		luasnip.jump(-1)
	else
		fallback()
	end
end

local function format(entry, vim_item)
	vim_item.kind = string.format("%s", KIND_ICONS[vim_item.kind])
	vim_item.menu = ({
		nvim_lsp = "[Lsp]",
		luasnip = "[Snippet]",
		buffer = "[Buffer]",
		path = "[Path]",
	})[entry.source.name]

	return vim_item
end

return {
	setup = function()
		luasnip_loader.lazy_load()

		cmp.setup({
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = {
				["<CR>"] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Insert,
					select = true,
				}),
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
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
		})
	end,
	capabilities = capabilities,
}
