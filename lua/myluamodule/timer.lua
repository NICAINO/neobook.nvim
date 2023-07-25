M = {}

local function center_text(text)
	local width = vim.api.nvim_win_get_width(0) - 10
	local shift = math.floor(width / 2) - math.floor(string.len(text) / 2)
	return string.rep(" ", shift) .. text
end

M.start_timer = function()
	return os.time()
end

M.time_remaining = function(start_time, duration_min)
	local time_passed = os.time() - start_time
	return 60 * duration_min - time_passed
end

M.timer_to_lines = function(timer_value)
	local timer_lines = {}
	for i = 0, 3 do
		table.insert(timer_lines, "")
	end
	table.insert(timer_lines, center_text("Timer"))
	table.insert(timer_lines, center_text(""))
	if timer_value ~= nil then
		local remaining = M.time_remaining(Garden_state.timer, 2)
		local timer_string = math.floor(remaining / 60).tostring() .. ":" .. (remaining % 60).tostring()
		table.insert(timer_lines, center_text(timer_string))
	else
		table.insert(timer_lines, center_text("Start timer with s"))
	end
	return timer_lines
end

return M
