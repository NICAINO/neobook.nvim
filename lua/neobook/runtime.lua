local inspect = require("../neobook/inspect")

M = {}

local function spawn_terminal()
	local buffer = nil
	local channel = nil
	local old_buffers = vim.api.nvim_list_bufs()
	local old_channels = vim.api.nvim_list_chans()
	vim.cmd("terminal")

	local new_buffers = vim.api.nvim_list_bufs()
	local new_channels = vim.api.nvim_list_chans()
	for _, chan in ipairs(new_channels) do
		if not vim.tbl_contains(old_channels, chan) then
			channel = chan.id
			break
		end
	end
	print("channel", inspect(channel))

	for _, buf in ipairs(new_buffers) do
		if not vim.tbl_contains(old_buffers, buf) then
			buffer = buf
			break
		end
	end

  vim.api.nvim_chan_send(channel, ['ls'])

	return buffer
end

M.begin_runtime = function()
	local terminal_buffer = spawn_terminal()
	print("terminal_buffer", terminal_buffer)
end

return M
