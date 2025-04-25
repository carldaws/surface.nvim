local M = {}

M.mappings = {}
M.terminals = {}

function M.setup(opts)
	M.mappings = opts.mappings or {}

	for _, mapping in ipairs(M.mappings) do
		vim.api.nvim_set_keymap("n", mapping.keymap, string.format(
			"<cmd>lua require('surface').open('%s')<CR>", vim.fn.escape(mapping.command, "'")
		), { noremap = true, silent = true })
	end
end

function M.open(command)
	local terminal_data = M.terminals[command]
	local buffer = terminal_data and terminal_data.buffer

	if not buffer or not vim.api.nvim_buf_is_valid(buffer) then
		buffer = vim.api.nvim_create_buf(false, true)
		M.terminals[command] = { buffer = buffer, position = "center" }
	end

	local window_config = M.window_config_for(M.terminals[command])
	local window = vim.api.nvim_open_win(buffer, true, window_config)

	M.terminals[command].window = window

	if vim.fn.bufname(buffer) == "" then
		local shell = os.getenv("SHELL") or "/bin/sh"
		local job_id = vim.fn.termopen({ shell, "-c", command .. "; exec " .. shell })
		vim.b[buffer].terminal_job_id = job_id

		vim.api.nvim_buf_set_keymap(buffer, "t",
			"<Esc><Esc>", "<C-\\><C-n>:lua require('surface').hide('" .. command .. "')<CR>",
			{ noremap = true, silent = true }
		)

		vim.api.nvim_buf_set_keymap(buffer, "t", "<Esc><Left>",
			string.format("<C-\\><C-n>:lua require('surface').move('%s', 'left')<CR>i", vim.fn.escape(command, "'")),
			{ noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(buffer, "t", "<Esc><Down>",
			string.format("<C-\\><C-n>:lua require('surface').move('%s', 'bottom')<CR>i", vim.fn.escape(command, "'")),
			{ noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(buffer, "t", "<Esc><Up>",
			string.format("<C-\\><C-n>:lua require('surface').move('%s', 'top')<CR>i", vim.fn.escape(command, "'")),
			{ noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(buffer, "t", "<Esc><Right>",
			string.format("<C-\\><C-n>:lua require('surface').move('%s', 'right')<CR>i", vim.fn.escape(command, "'")),
			{ noremap = true, silent = true }
		)
		vim.api.nvim_buf_set_keymap(buffer, "t", "<Esc>c",
			string.format("<C-\\><C-n>:lua require('surface').move('%s', 'center')<CR>i", vim.fn.escape(command, "'")),
			{ noremap = true, silent = true }
		)
	end

	vim.api.nvim_command("startinsert")
end

function M.move(command, position)
	local terminal = M.terminals[command]
	M.terminals[command].position = position

	local window_config = M.window_config_for(terminal)
	vim.api.nvim_win_set_config(terminal.window, window_config)
end

function M.window_config_for(terminal)
	local width = vim.o.columns
	local height = vim.o.lines

	local window_config = {
		style = "minimal",
		relative = "editor",
		border = "rounded"
	}

	if terminal.position == "bottom" then
		window_config.width = width - 2
		window_config.height = math.floor(height / 2)
		window_config.row = (height - window_config.height) - 1
		window_config.col = 1
	elseif terminal.position == "top" then
		window_config.width = width - 2
		window_config.height = math.floor(height / 2)
		window_config.row = 1
		window_config.col = 1
	elseif terminal.position == "left" then
		window_config.width = math.floor(width / 2)
		window_config.height = height - 4
		window_config.row = 1
		window_config.col = 1
	elseif terminal.position == "right" then
		window_config.width = math.floor(width / 2)
		window_config.height = height - 4
		window_config.row = 1
		window_config.col = width - window_config.width
	elseif terminal.position == "center" then
		window_config.width = math.floor(width * 0.8)
		window_config.height = math.floor(height * 0.8)
		window_config.row = math.floor((height - window_config.height) / 2)
		window_config.col = math.floor((width - window_config.width) / 2)
	end

	return window_config
end

function M.hide(command)
	local terminal = M.terminals[command]
	if terminal and terminal.window and vim.api.nvim_win_is_valid(terminal.window) then
		vim.api.nvim_win_close(terminal.window, true)
		M.terminals[command].window = nil
	end
end

return M
