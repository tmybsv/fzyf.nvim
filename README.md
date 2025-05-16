![fzyf.nvim example](./doc/ex.png)

fast and minimal as fuck neovim fuzzy finder that using fzy under the hood

## dependencies

- fzy
- ripgrep
- fd

## installation

any plugin manager that you like

e.g. using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- if init.lua
{
	"tmybsv/fzyf.nvim",
}

-- if plugins/fzyf.lua
return {
	"tmybsv/fzyf.nvim",
}
```

## usage

```lua
local fzyf = require("fzyf")
fzyf.setup({
    vim.keymap.set("n", "<leader>ff", ":FzyfFindFile<CR>", { silent = true }),
    vim.keymap.set("n", "<leader>fl", ":FzyfLiveGrep<CR>", { silent = true }),
})
```
