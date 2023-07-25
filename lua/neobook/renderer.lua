local inspect = require("../neobook/inspect")

M = {}

-- TODO: Now hardcoded but should be respective to the language
local comment_string = '"""'

local function render_output(outputs) end

-- TODO: The comments are now hardcoded to be python or julia, however this should kinda be inferred
local function cell_divider(cell_type, language)
	if cell_type == nil then
		local line = "#"
		for i = 1, 78 do
			line = line .. "="
		end
		line = line .. "#"
		return line
	elseif cell_type == "markdown" then
		local diff = 76 - #cell_type
		local line = "# " .. cell_type .. " "
		for i = 1, diff do
			line = line .. "="
		end
		line = line .. "#"
		return line
	else
		local diff = 76 - #language
		local line = "# " .. language .. " "
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
				table.insert(output_lines, comment_string)
				table.insert(output_lines, "Output: " .. i)
				for type, data in pairs(output.data) do
					if type == "text/html" then
						table.insert(output_lines, "#HTML :<")
					elseif type == "text/plain" then
						for j, line in pairs(data) do
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

M.generate_float = function(buffer, state)
	if buffer == nil then
		buffer = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_buf_set_name(buffer, "temp")
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
