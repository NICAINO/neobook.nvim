-- By convention, nvim Lua plugins include a setup function that takes a table
-- so that users of the plugin can configure it using this pattern:

local renderer = require("../neobook/renderer")
local inspect = require("../neobook/inspect")
local utils = require("../neobook/utils")
local dkjson = require("/neobook/dkjson")
local runtime = require("../neobook/runtime")

Settings = {}
Notebook_state = {}
Render_state = {
	buffers = {},
	windows = { "", "", "", "" },
	window_handles = { nil, nil, nil, nil },
}

-- require'myluamodule'.setup({p1 = "value1"})
local function setup(parameters)
	Settings = {
		split_num = 4,
	}
	Notebook_state = {}
end

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
	-- local old_window = vim.api.nvim_get_current_win()
	-- renderer.render_split(Notebook_state, Render_state)
	-- vim.api.nvim_win_close(old_window, false)
	renderer.generate_float(nil, Notebook_state)
end, {})

vim.api.nvim_create_user_command("NeobookBuild", function()
	local cells = {}
	local cell_dividers = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
	for i, line in pairs(lines) do
		if string.sub(line, 1, 3) == "#= " then
			if string.sub(line, 4, 11) == "markdown" then
				table.insert(cell_dividers, i)
				table.insert(cells, {
					cell_type = "markdown",
					source = {},
					metadata = {},
				})
			elseif string.sub(line, 4, 9) == "output" then
				-- Unlucky lua no continue keyword
				goto continue
			else
				table.insert(cell_dividers, i)
				table.insert(cells, {
					cell_type = "code",
					execution_count = 1,
					source = {},
					metadata = {},
					outputs = {},
				})
			end
			::continue::
		end
	end
	table.insert(cell_dividers, #lines - 1)

	local previous = cell_dividers[1]
	for i, cell_divider in pairs(cell_dividers) do
		if cell_dividers ~= previous then
			local cell_lines = {}
			-- WARNING: This might have funky behaviour at the last cell
			for j = previous, cell_divider - 1 do
				table.insert(cell_lines, lines[j])
				table.insert(cells[i - 1].source, lines[j])
			end
			-- print(inspect(cell_lines))
			previous = cell_divider
		end
	end

	--Trims and parses the cells
	-- TODO: Proporly trim and build the outputs
	for _, cell in pairs(cells) do
		local start_end = { 1 }
		for i, line in pairs(cell.source) do
			if i == 1 then
				goto continue
			end
			if string.sub(line, 1, 3) == "#= " then
				table.insert(start_end, i - 2)
				table.insert(start_end, i)
			end
			::continue::
		end
		table.insert(start_end, #cell.source - 1)

		--Determine cell source and outputs
		local blocks = {}
		for i = 1, #start_end, 2 do
			local block = {}
			for j = start_end[i], start_end[i + 1] do
				table.insert(block, cell.source[j])
			end
			table.insert(blocks, block)
		end

		--empty source
		while #cell.source > 0 do
			table.remove(cell.source)
		end

		--Parse blocks and repopulate source
		for _, block in pairs(blocks) do
			local block_ident = string.sub(block[1], 4, 11)

			if block_ident == "markdown" then
				for i = 3, #block do
					table.insert(cell.source, block[i])
				end
			elseif block_ident == "output: " then
				local output_lines = {}
				for i = 3, #block do
					table.insert(output_lines, block[i])
				end
				local output_type = string.sub(block[1], 17, 21)
				if output_type == "plain" then
					table.insert(cell.outputs, { data = {} })
					cell.outputs[1].data["text/plain"] = output_lines
				elseif output_type == "html " then
					table.insert(cell.outputs, { data = {} })
					cell.outputs[1].data["text/html"] = output_lines
				end
			elseif block_ident == "python =" or "julia ==" then
				for i = 3, #block do
					table.insert(cell.source, block[i])
				end
			else
				print("Block type was not recognized/implemented: ", block_ident)
			end
		end
		-- print("Cell", inspect(cell))
	end

	-- Build the json and write to output file
	local file = io.open("output.ipynb", "w")
	if file == nil then
		print("Error opening file")
		return
	end
	local cell_json = dkjson.encode({ cells = cells }, {
		indent = true,
		keyorder = { "cell_type", "execution_count", "metadata", "outputs", "source" },
		__jsontype = "array",
	})
	if type(cell_json) == "string" then
		file:write(cell_json)
	end
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
	runtime.begin_runtime()
end, {})

function Test(buffer)
	print(inspect(vim.api.nvim_buf_get_lines(buffer, 0, -1, true)))
end
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
