local inspect = require("../neobook/inspect")

M = {}

-- TODO: Now hardcoded but should be respective to the language
local comment_string = '"""'

local function render_output(outputs) end

-- TODO: The comments are now hardcoded to be python or julia, however this should kinda be inferred
local function cell_divider(cell_type, language)
	if cell_type == nil then
		local line = "#="
		for i = 1, 78 do
			line = line .. "="
		end
		line = line .. "#"
		return line
	elseif cell_type == "markdown" then
		local diff = 75 - #cell_type
		local line = "#= " .. cell_type .. " "
		for i = 1, diff do
			line = line .. "="
		end
		line = line .. "#"
		return line
	else
		local diff = 75 - #language
		local line = "#= " .. language .. " "
		for i = 1, diff do
			line = line .. "="
		end
		line = line .. "#"
		return line
	end
end

local function format(string)
	local formatted = string.gsub(string, "\n", "")
	return formatted
end

-- local function spawn_split(settings, buffer)
-- 	vim.cmd("split")
-- 	local window = vim.api.nvim_get_current_win()
-- 	vim.api.nvim_win_set_buf(window, buffer)
-- 	return window
-- 	-- vim.api.nvim_win_set_height(window, 1 + vim.api.nvim_buf_line_count(buffer))
-- end

-- TODO: Should probabl be relative and not hardcoded
local function draw_cell(cell)
	local output_lines = {}
	if cell.cell_type == "markdown" then
		table.insert(output_lines, comment_string)
		local formatted_source = {}
		-- print("Output lines", inspect(cell.source))
		for i, source_line in pairs(cell.source) do
			local fmt = string.gsub(source_line, "\n", "")
			table.insert(formatted_source, fmt)
		end
		for i, line in pairs(formatted_source) do
			table.insert(output_lines, line)
		end
		table.insert(output_lines, comment_string)
	elseif cell.cell_type == "code" then
		table.insert(output_lines, "")
		local formatted_source = {}
		-- print("Output lines", inspect(cell.source))
		for i, source_line in pairs(cell.source) do
			local fmt = string.gsub(source_line, "\n", "")
			table.insert(formatted_source, fmt)
		end
		for i, line in pairs(formatted_source) do
			table.insert(output_lines, line)
		end
		table.insert(output_lines, "")

		if cell.outputs[1] ~= nil then
			for i, output in pairs(cell.outputs) do
				-- TODO: Should be a separate type not just code type
				-- FIX: output.data does not always exits (some just have the field text)

				for type, data in pairs(output.data) do
					table.insert(output_lines, cell_divider("code", "output: " .. type))
					table.insert(output_lines, comment_string .. type)
					-- if type == "text/html" then
					-- 	-- TODO: Maybe host html locally or something
					--
					-- 	table.insert(output_lines, "#HTML :<")
					if type == "text/plain" or type == "text/html" then
						for _, line in pairs(data) do
							table.insert(output_lines, format(line))
						end
						table.insert(output_lines, comment_string)
					else
						print(inspect(type))
					end
				end
			end
		end
	end
	return output_lines
end

-- local function rezise_to_fit(render_state)
-- 	for i, buffer in pairs(render_state.windows) do
-- 		local height = vim.api.nvim_buf_line_count(buffer) + 1
-- 		vim.api.nvim_win_set_height(render_state.window_handles[i], height)
-- 		-- FIX: Something with the window handles or the timing of the resize is broken
-- 		print(render_state.window_handles[i])
-- 	end
-- end

-- M.render_split = function(state, render_state)
-- 	local total_height = vim.api.nvim_win_get_height(0)
-- 	for i, cell in pairs(state.cells) do
-- 		local buffer = vim.api.nvim_create_buf(true, false)
-- 		render_state.buffers[i] = buffer
-- 		vim.api.nvim_buf_set_name(buffer, "Nb" .. i)
--
-- 		local cell_lines = {}
--
-- 		for j, line in pairs(draw_cell(cell)) do
-- 			table.insert(cell_lines, line)
-- 		end
-- 		vim.api.nvim_buf_set_lines(buffer, 0, 0, true, cell_lines)
-- 		if cell.cell_type == "markdown" then
-- 			vim.api.nvim_buf_set_option(buffer, "filetype", "markdown")
-- 		elseif cell.cell_type == "code" then
-- 			vim.api.nvim_buf_set_option(buffer, "filetype", state.kernel_language)
-- 		end
--
-- 		total_height = total_height - #cell_lines - 1
-- 		print(total_height)
-- 		if total_height >= #cell_lines + 1 then
-- 			render_state.windows[i] = buffer
-- 			render_state.window_handles[i] = spawn_split({}, buffer)
-- 		end
-- 	end
-- 	rezise_to_fit(render_state)
-- end

M.generate_float = function(buffer, state)
	if buffer == nil then
		buffer = vim.api.nvim_create_buf(true, true)
		-- vim.api.nvim_buf_set_name(buffer, "temp")
		vim.api.nvim_buf_set_option(buffer, "filetype", state.kernel_language)
	end

	local output_lines = {}

	for i, cell in pairs(state.cells) do
		table.insert(output_lines, cell_divider(cell.cell_type, state.kernel_language))
		for j, line in pairs(draw_cell(cell)) do
			table.insert(output_lines, line)
		end
	end
	table.insert(output_lines, cell_divider(nil))
	vim.api.nvim_buf_set_lines(buffer, 0, 0, true, output_lines)
	vim.api.nvim_win_set_buf(0, buffer)
end

M.render_notebook = function(cells, code_language) end

return M
