---@class MT2C
local M = {}

---@return string
M.selected_text_lines = function()
	local current_buf = vim.api.nvim_get_current_buf()
	local start_line = vim.fn.line("'<") - 1
	local end_line = vim.fn.line("'>")
	local lines = vim.api.nvim_buf_get_lines(current_buf, start_line, end_line, false)
	local selected_table = table.concat(lines, "\n")
	return selected_table
end

---@param markdown_table string
---@return table
M.splitted_lines = function(markdown_table)
	local lines = {}
	for line in markdown_table:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end
	return lines
end

---@param lines table
---@return table
M.transformed_csv_outs = function(lines)
	local csv_outs = {}
	for i, line in ipairs(lines) do
		-- skip separator
		if i ~= 2 then
			-- '|'で分割
			local cells = {}
			for cell in line:gmatch("|?%s*(.-)%s*|") do
				table.insert(cells, cell)
			end
			table.insert(csv_outs, table.concat(cells, ", "))
		end
	end
	return csv_outs
end

M.ConvertedMarkdownTable = function()
	local markdown_table = M.selected_text_lines()
	local lines = M.splitted_lines(markdown_table)
	local transformed_table = M.transformed_csv_outs(lines)
	local csv = table.concat(transformed_table, "\n")

	-- register to clipboard
	vim.fn.setreg("+", csv)
end

M.setup = function()
	local wrapped_converter = function()
		return M.ConvertedMarkdownTable()
	end
	vim.api.nvim_set_keymap("v", "<Leader>mtc", "<Cmd>lua wrapped_converter()<CR>", { noremap = true, silent = true })
end

return M
