require("analemma.core.options")
require("analemma.core.packman")
require("analemma.keymap.remap")
vim.cmd('colorscheme desert')
vim.cmd('highlight Normal ctermbg=None')
vim.cmd('highlight EndOfBuffer ctermbg=None')

vim.g.clipboard = {
	name = "win32yank-wsl",
	copy = {
		["+"] = "win32yank.exe -i --crlf",
		["*"] = "win32yank.exe -i --crlf",
	},
	paste = {
		["+"] = "win32yank.exe -o --lf",
		["*"] = "win32yank.exe -o --lf",
	},
	cache_enabled = 0,
}
