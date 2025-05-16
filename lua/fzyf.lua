--- @param cmd string
--- @param tempf string
local function open_terminal(cmd, tempf)
	local status = vim.fn.jobstart(cmd .. tempf, {
		on_exit = function()
			vim.api.nvim_command("bd!")
			local f = io.open(tempf, "r")
			if f == nil then
				return
			end
			local stdout = f:read("l")
			vim.api.nvim_command("e " .. stdout)
		end,
	})
	if status == -1 or status == 0 then
		error("failed to open terminal")
	end
end

-- TODO: implement window configuration
local function spawn_float()
	local width = vim.o.columns - 30
	local height = vim.o.lines - 10
	vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), true, {
		relative = "editor",
		style = "minimal",
		width = width,
		height = height,
		col = math.min((vim.o.columns - width) / 2),
		row = math.min((vim.o.lines - height) / 2),
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
