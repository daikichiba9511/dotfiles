-- Description:
--    Preview image in terminal using wezterm imgcat
--
-- Usage:
--     :ImgCat /path/to/image.png
--
-- Status: WIP (only works on wezterm)
--
-- TODO:
-- 1. Add completion for image path
--
-- Prerequirements:
-- - wezterm
--
-- Reference
-- 1. https://zenn.dev/link/comments/d9547142490c77
-- 2. https://github.com/adelarsq/image_preview.nvim/blob/main/lua/image_preview/init.lua
-- 3. https://github.com/nvim-telescope/telescope-media-files.nvim/blob/master/lua/telescope/_extensions/media_files.lua
-- 4. https://zenn.dev/kawarimidoll/articles/36b1cc92d00453
--

--- Check if file is in the directory -@param fp string -@param directory string -@return boolean local function is_file_in_the_directory(fp, directory) return fp:find(directory, 1, true) == 1 end

--- Find image files in directory
---@param directory string
---@return string[]
local function find_images_in_dir(directory)
	if vim.fn.executable("fd") == 0 then
		error("fd is not installed or not executable. Please install fd and try again.")
	end

	-- Make command to find image files
	local wanted_extensions = { "jpg", "jpeg", "png" }
	local command = "fd -e " .. table.concat(wanted_extensions, " -e ")
	command = command .. " --type f --hidden --no-ignore-vcs --color=never . " .. directory

	-- open with read mode
	local handle = io.open(command, "r")
	if handle == nil then
		error("Failed to open fd output")
	end
	local result = handle:read("*a")
	if result == nil then
		error("Failed to read fd output")
	end
	handle:close()

	-- Get image paths
	local image_paths = {}
	for path in result:gmatch("[^\r\n]+") do
		if is_file_in_the_directory(path, directory) then
			table.insert(image_paths, path)
		end
	end

	return image_paths
end

local function has_valid_extension(fp, ext)
	return fp:match("^.+%." .. ext .. "$") ~= nil
end

---@class ImagePreview
local M = {}

--- Preview image in terminal using wezterm imgcat
---@param fp string
M.ImagePreview = function(fp)
	local absolte_path = vim.fn.expand(fp)
	if absolte_path == nil then
		error("Failed to get absolute path")
	end
	local wanted_extensions = { "jpg", "jpeg", "png" }
	local is_valid_extension = false
	for _, ext in ipairs(wanted_extensions) do
		if has_valid_extension(absolte_path, ext) then
			is_valid_extension = true
			break
		end
	end
	if not is_valid_extension then
		error("Invalid extension")
	end

	local command = {
		"silent ",
		"!wezterm cli split-pane ",
		"-- ",
		"bash ",
		"-c ",
		"'wezterm imgcat '" .. absolte_path .. "'; read'",
	}
	vim.api.nvim_command(table.concat(command, ""))
end

M.setup = function()
	function WrappedImagePreview(fp)
		M.ImagePreview(fp)
	end

	vim.api.nvim_create_user_command("ImgCat", "lua WrappedImagePreview(<q-args>)", {
		nargs = 1,
		-- complete = function(arg_lead, _, _)
		-- 	local out = {}
		-- 	local current_dir = vim.fn.getcwd()
		-- 	if arg_lead == "" or current_dir == nil then
		-- 		return out
		-- 	end
		-- 	local complete_list = find_images_in_dir(current_dir)
		-- 	for _, v in ipairs(complete_list) do
		-- 		table.insert(out, v)
		-- 	end
		-- 	return out
		-- end,
	})
	-- vim.api.nvim_set_keymap("n", "<leader>ip", ":ImgCat<CR>", { noremap = true, silent = true })
end

return M
