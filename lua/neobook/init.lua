-- By convention, nvim Lua plugins include a setup function that takes a table
-- so that users of the plugin can configure it using this pattern:

local renderer = require("../neobook/renderer")
local inspect = require("../neobook/inspect")
local utils = require("../neobook/utils")
--
-- require'myluamodule'.setup({p1 = "value1"})
local function setup(parameters)
	Notebook_state = {}
end

Notebook_state = {}

function global_lua_function()
	print("nvim-example-lua-plugin.myluamodule.init global_lua_function: hello")
end

local function local_lua_function()
	print("nvim-example-lua-plugin.myluamodule.init local_lua_function: hello")
end

-- TODO: Make it failable
vim.api.nvim_create_user_command("Neobook", function()
	local cells, metadata = utils.load_notebook(vim.api.nvim_buf_get_lines(0, 0, -1, true))
	Notebook_state.cells = cells
	Notebook_state.metadata = metadata
	Notebook_state.kernel_language = metadata.language_info.name
	-- vim.treesitter.language.register(Notebook_state.kernel_language, "notebook")
	print(inspect(Notebook_state.kernel_language))
	renderer.generate_float(nil, Notebook_state)
end, {})

-- keymappi-- Create a named autocmd group for autocmds so that if this file/plugin gets reloaded, the existing
-- autocmd group will be cleared, and autocmds will be recreated, rather than being duplicated.
local augroup = vim.api.nvim_create_augroup("highlight_cmds", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "rubber",
	group = augroup,
	-- There can be a 'command', or a 'callback'. A 'callback' will be a reference to a Lua function.
	command = "highlight String guifg=#FFEB95",
	--callback = function()
	--  vim.api.nvim_set_hl(0, 'String', {fg = '#FFEB95'})
	--end
})

vim.api.nvim_create_user_command("Test", function()
	print(inspect(vim.api.nvim_get_namespaces()))
	print(inspect(vim.api.nvim_buf_get_extmarks(0, 13, 0, 2, {})))
end, {})

-- Returning a Lua table at the end allows fine control of the symbols that
-- will be available outside this file. Returning the table also allows the
-- importer to decide what name to use for this module in their own code.
--
-- Examples of how this module can be imported:
--    local mine = require('myluamodule')
--    mine.local_lua_function()
--    local myluamodule = require('myluamodule')
--    myluamodule.local_lua_function()
--    require'myluamodule'.setup({p1 = "value1"})
return {
	setup = setup,
	local_lua_function = local_lua_function,
}
