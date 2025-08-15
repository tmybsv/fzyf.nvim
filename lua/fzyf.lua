local M = {}

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

local function open_terminal(pipeline, tempf)
	local status = vim.fn.termopen(pipeline .. " > " .. vim.fn.shellescape(tempf), {
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

local function execute_pipeline(pipeline)
	spawn_float()
	vim.cmd("startinsert")
	local tmp = vim.fn.tempname()
	open_terminal(pipeline, tmp)
end

local function fzy_list_height()
	return math.max(10, vim.o.lines - 10)
end

local function find_file()
	local pipeline = string.format("fd -tf --color=never . | fzy -l %d", fzy_list_height())
	execute_pipeline(pipeline)
end

local function lookup_config()
	local cfgdir = vim.fn.stdpath("config")
	local pipeline = string.format(
		"fd -tf --color=never . %s | fzy -l %d",
		vim.fn.shellescape(cfgdir),
		fzy_list_height()
	)
	execute_pipeline(pipeline)
end

local function live_grep()
	local rg = table.concat({
		"rg --vimgrep --no-heading --color=never --smart-case .",
		"awk -F':' '!seen[$1\":\"$2]++ {printf \"+%s %s\n\", $2, $1}'",
	}, " | ")
	local pipeline = string.format("%s | fzy -l %d", rg, fzy_list_height())
	execute_pipeline(pipeline)
end

function M.setup()
	vim.api.nvim_create_user_command("FzyfFindFile", find_file, {})
	vim.api.nvim_create_user_command("FzyfLiveGrep", live_grep, {})
	vim.api.nvim_create_user_command("FzyfLookupConfig", lookup_config, {})
end

return M
