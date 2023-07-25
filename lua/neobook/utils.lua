local json = require("../neobook/json")

M = {}

M.load_notebook = function(buffer_lines)
	local base_to_string = ""
	for i, line in ipairs(buffer_lines) do
		base_to_string = base_to_string .. line
	end
	local value = json.decode(base_to_string)
	local cells = value.cells
	local metadata = value.metadata
	return cells, metadata
end

-- From stackoverflow
M.dump = function(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

return M
