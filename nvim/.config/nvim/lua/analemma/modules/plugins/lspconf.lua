return {
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v4.x',
		dependencies = {
			{'neovim/nvim-lspconfig'},
  			{'hrsh7th/cmp-nvim-lsp'},
  			{'hrsh7th/nvim-cmp'},
			{'williamboman/mason.nvim'},
  			{'williamboman/mason-lspconfig.nvim'},
			{'FelipeLema/cmp-async-path'},
		},
		config = function()
			local lsp_zero = require('lsp-zero')

			local lsp_attach = function(client, bufnr)
				local opts = {buffer = bufnr}
				
				vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
				vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
				vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
				vim.keymap.set('n', 'gm', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
				vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
				vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
				vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
				vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
				vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
				vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
			end

			lsp_zero.extend_lspconfig({
				sign_text = true,
				lsp_attach = lsp_attach,
				capabilities = require('cmp_nvim_lsp').default_capabilities(),
			})

			require('mason').setup({})
			require('mason-lspconfig').setup({
  				handlers = {
    				function(server_name)
      					require('lspconfig')[server_name].setup({})
    				end,
				lua_ls = function()
					require('lspconfig').lua_ls.setup({
						on_init = function(client)
							lsp_zero.nvim_lua_settings(client, {})
					end,
					})
				end,
				},
			})
			local cmp = require('cmp')
			local cmp_action = require('lsp-zero').cmp_action()
			
			local has_words_before = function()
 				unpack = unpack or table.unpack
 				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
 				return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end


			cmp.setup({
				view = {
					entries = { name = "wildmenu", separator = " ~ " }
				},
  				sources = {
    				{name = 'nvim_lsp'},
					{name = 'async_path'},
  				},
  				snippet = {
    				expand = function(args)
      					-- You need Neovim v0.10 to use vim.snippet
      					vim.snippet.expand(args.body)
    				end,
  				},
  				mapping = {
    					['<C-u>'] = cmp.mapping.scroll_docs(-4),
    					['<C-d>'] = cmp.mapping.scroll_docs(4),
						['<C-Space>'] = cmp.mapping.complete();
						['<Tab>'] = cmp.mapping(function(fallback)
					    if cmp.visible() then
					    	if #cmp.get_entries() == 1 then
					        	cmp.confirm({ select = true })
					        else
					        	cmp.select_next_item()
					        end
					      elseif has_words_before() then
					    	cmp.complete()
					    	if #cmp.get_entries() == 1 then
					        	cmp.confirm({ select = true })
					        end
					      else
							fallback()
					      end
					    end, { "i", "s" }),
				},
			})
		end
	},
}

