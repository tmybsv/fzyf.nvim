-- TODO: implement window configuration
local function spawnfloat()
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

local function findfile()
	spawnfloat()
	vim.api.nvim_command("startinsert")
	local tempf = vim.fn.tempname()
	local cmd = "fd -tf -cnever . | fzy -l" .. vim.o.lines - 10 .. " > "
	vim.fn.termopen(cmd .. tempf, {
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
end

local function livegrep()
	spawnfloat()
	vim.api.nvim_command("startinsert")
	local tempf = vim.fn.tempname()
	vim.fn.termopen(
		"rg -i --vimgrep . | awk -F':' '!seen[$1\":\"$2]++' | fzy -l25 | awk -F':' '{print \"+\"$2, $1}' > " .. tempf,
		{
			on_exit = function()
				vim.api.nvim_command("bd!")
				local f = io.open(tempf, "r")
				if f == nil then
					return
				end
				local stdout = f:read("l")
				vim.api.nvim_command("e " .. stdout)
			end,
		}
	)
end

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("FzyfFindFile", function()
		findfile()
	end, {})
	vim.api.nvim_create_user_command("FzyfLiveGrep", function()
		livegrep()
	end, {})
end

return M
