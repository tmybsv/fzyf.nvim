--- @param cmd string
--- @param tempf string
local function open_terminal(cmd, tempf)
	local status = vim.fn.termopen(cmd .. " > " .. vim.fn.shellescape(tempf), {
		on_exit = function()
			vim.api.nvim_command("bd!")
			local f = io.open(tempf, "r")
			if not f then return end
			local out = f:read("*l")
			f:close()
			pcall(vim.loop.fs_unlink, tempf)
			if not out or out == "" then return end
			local lnum, file = out:match("^%+(%d+)%s+(.+)$")
			if file then
				vim.cmd(string.format("edit +%s %s", lnum, vim.fn.fnameescape(file)))
			else
				vim.cmd("edit " .. vim.fn.fnameescape(out))
			end
		end,
	})
	if not status or status <= 0 then
		error("termopen failed")
	end
end

-- TODO: implement window configuration
local function spawn_float()
	local cols, lines = vim.o.columns, vim.o.lines
	local width = math.max(40, cols - 30)
	local height = math.max(10, lines - 10)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		width = width,
		height = height,
		col = math.floor((cols - width) / 2),
		row = math.floor((lines - height) / 2),
		border = "none",
	})
end

--- @param cmd string
local function execute_cmd(cmd)
	spawn_float()
	vim.api.nvim_command("startinsert")
	local tempf = vim.fn.tempname()
	open_terminal(cmd, tempf)
end

local function find_file()
	local cmd = "fd -tf -cnever . | fzy -l" .. vim.o.lines - 10 .. " > "
	execute_cmd(cmd)
end

local function lookup_config()
	local cfgdir = vim.fn.stdpath("config")
	local cmd = "fd -tf -cnever . " .. cfgdir .. " | fzy -l" .. vim.o.lines - 10 .. " > "
	execute_cmd(cmd)
end

local function live_grep()
	-- TODO: improve livegrep cmd
	local cmd = "rg -i --vimgrep . | awk -F':' '!seen[$1\":\"$2]++' | fzy -l25 | awk -F':' '{print \"+\"$2, $1}' > "
	execute_cmd(cmd)
end

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("FzyfFindFile", function()
		find_file()
	end, {})
	vim.api.nvim_create_user_command("FzyfLiveGrep", function()
		live_grep()
	end, {})
	vim.api.nvim_create_user_command("FzyfLookupConfig", function()
		lookup_config()
	end, {})
end

return M
