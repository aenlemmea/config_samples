return {
    "ptdewey/yankbank-nvim",
    dependencies = "kkharji/sqlite.lua",
    config = function()
        require('yankbank').setup({
            persist_type = "sqlite",
        })
		vim.keymap.set("n", "<leader>y", "<cmd>YankBank<CR>", {noremap = true})
    end,
}
