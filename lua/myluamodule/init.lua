-- By convention, nvim Lua plugins include a setup function that takes a table
-- so that users of the plugin can configure it using this pattern:

local timer = require("../myluamodule/timer")
--
-- require'myluamodule'.setup({p1 = "value1"})
local function setup(parameters)
	vim.api.nvim_set_keymap("n", "Z", ":Tend<CR>", {})
	local lines = {}
	for i = 1, 300 do
		if i % 2 == 0 then
			lines[i] = 1
		else
			lines[i] = 0
		end
	end
	Garden_state.data = {
		dimensions = {
			height = 10,
			width = 30,
		},
		garden = lines,
	}
	Garden_state.timer = nil
	print("Setup happaned")
end

Garden_state = {}

function global_lua_function()
	print("nvim-example-lua-plugin.myluamodule.init global_lua_function: hello")
end

local function local_lua_function()
	print("nvim-example-lua-plugin.myluamodule.init local_lua_function: hello")
end

-- Generated with chatgippity
local function center_text(text)
	local width = vim.api.nvim_win_get_width(0) - 10
	local shift = math.floor(width / 2) - math.floor(string.len(text) / 2)
	return string.rep(" ", shift) .. text
end

-- These obviously should not be hardcoded
local function garden_to_lines(garden, dimensions)
	local garden_lines = {}
	for i = 0, 3 do
		table.insert(garden_lines, "")
	end
	table.insert(garden_lines, center_text("Garden"))
	table.insert(garden_lines, center_text(""))
	table.insert(garden_lines, center_text("*------------------------------*"))
	for i = 1, dimensions.height do
		local line = "|"
		for j = 1, dimensions.width do
			line = line .. tostring(garden[i * j])
		end
		line = line .. "|"
		table.insert(garden_lines, center_text(line))
	end
	table.insert(garden_lines, center_text("*------------------------------*"))
	return garden_lines
end

vim.api.nvim_create_user_command("StartTimer", function()
	local start = timer.start_timer()
	Garden_state.timer = start
	print("Timer started at: ", start)
end, {})

vim.api.nvim_create_user_command("CheckTimer", function()
	print("Time remaining: ", timer.time_remaining(Garden_state.timer, 40), " seconds.")
end, {})

vim.api.nvim_create_user_command("Tend", function(input)
	--Need to add check whether buffer is alive but should prob do via state
	if Garden_state.focus then
		Garden_state.focus = false
		vim.api.nvim_win_close(0, false)
		return
	end
	local buffer = Garden_state.buffer
	if Garden_state.buffer == nil then
		buffer = vim.api.nvim_create_buf(false, false)
		Garden_state.buffer = buffer --buffer
		Garden_state.set_up = false --Setup?
	end
	if not Garden_state.set_up then
		local lines = timer.timer_to_lines(Garden_state.timer)
		vim.list_extend(lines, garden_to_lines(Garden_state.data.garden, Garden_state.data.dimensions))
		vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
		Garden_state.set_up = true
	end
	vim.api.nvim_buf_set_option(buffer, "modifiable", false)
	vim.api.nvim_open_win(buffer, true, {
		relative = "win",
		row = 5,
		col = 5,
		width = vim.o.columns - 10,
		height = vim.o.lines - 20,
		style = "minimal",
	})
	Garden_state.focus = true --Focus
	-- local keymap to start the timer
	vim.api.nvim_buf_set_keymap(buffer, "n", "s", ":StartTimer<CR>", {})
end, { bang = true, desc = "a new command to do the thing" })

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
