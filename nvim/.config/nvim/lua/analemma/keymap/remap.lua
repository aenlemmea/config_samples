vim.keymap.set("n", "<leader>r", "<C-^>", { silent = true, remap = false })
vim.keymap.set("n", ";", ":", { remap = false })
vim.keymap.set("v", ";", ":", { remap = false })


vim.keymap.set("n", "<leader>b", ":FzfLua buffers<CR>", { remap = false })
vim.keymap.set("n", "<leader>t", ":FzfLua tabs<CR>", { remap = false })
vim.keymap.set("n", "<leader>f", ":FzfLua git_files<CR>", { remap = false })
vim.keymap.set("n", "<leader>re", ":FzfLua diagnostics_document<CR>", { remap = false })
vim.keymap.set("n", "<leader>rw", ":FzfLua diagnostics_workspace<CR>", { remap = false })
vim.keymap.set("n", "<leader>se", ":FzfLua grep<CR>", { remap = false })
vim.keymap.set("n", "<leader>lse", ":FzfLua live_grep<CR>", { remap = false })
vim.keymap.set("n", "<leader>cse", ":FzfLua grep_cword<CR>", { remap = false })
