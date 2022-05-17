local nvim_lsp = require('lspconfig')
local cmp = require 'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` user.
        end
    },
    mapping = {
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<CR>'] = cmp.mapping.confirm({ select = true })
    },
    sources = {
        { name = 'nvim_lsp' }, { name = 'vsnip' }
        -- {name = 'buffer'}
    }
})

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<space>e',
    '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>',
    opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>',
    opts)
vim.api.nvim_set_keymap('n', '<space>q',
    '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

local on_attach = function(client, bufnr)
    local function set_key(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    local function set_opt(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    set_opt('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    set_key('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    set_key('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    set_key('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    set_key('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    set_key('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    set_key('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
        opts)
    set_key('n', '<space>wr',
        '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    set_key('n', '<space>wl',
        '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
        opts)
    set_key('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    set_key('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    set_key('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    set_key('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    set_key('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

    -- Set some keybinds conditional on server capabilities
    -- if client.server_capabilities.document_range_formatting then
    -- end
    set_key("v", "<leader>F", "<cmd>lua vim.lsp.buf.range_formatting()<CR>",
        opts)
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp
    .protocol
    .make_client_capabilities())

local servers = {
    "cmake", "pyright", "rust_analyzer", "hls", "elmls", "yamlls", "tsserver",
    "gopls", "rnix", "clojure_lsp", "jsonls"
}

for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup { on_attach = on_attach, capabilities = capabilities }
end

nvim_lsp["html"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "html" },
    init_options = {
        configurationSection = { "html", "css", "javascript" },
        embeddedLanguages = { css = true, javascript = true },
        provideFormatter = true
    },

    -- crashes without css.lint.validProperties
    settings = { css = { lint = { validProperties = {} } } }
}

nvim_lsp["ccls"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    init_options = {
        compilationDatabaseDirectory = "build",
        index = { threads = 0 },
        clang = { excludeArgs = { "-frounding-math" } }
    }
}

nvim_lsp["sumneko_lua"].setup {
    cmd = { "sumneko_lua" },
    on_attach = on_attach,
    capabilities = capabilities
}
nvim_lsp["efm"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "python", "lua" },
    init_options = { documentFormatting = true },
    settings = {
        languages = {
            python = {
                { formatCommand = "black --quiet -", formatStdin = true },
                { formatCommand = "isort --quiet -", formatStdin = true }
            },
            lua = { { formatCommand = "lua-format -i", formatStdin = true } }
        }
    }
}
nvim_lsp["texlab"].setup {
    cmd = { "texlab" },
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "tex", "bib" },
    settings = {
        texlab = {
            bibtexFormatter = "texlab",
            build = {
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                executable = "latexmk",
                forwardSearchAfter = true,
                onSave = true
            },
            chktex = { onEdit = true, onOpenAndSave = true },
            diagnosticsDelay = 300,
            formatterLineLength = 80,
            forwardSearch = {
                executable = "zathura",
                args = { "--synctex-forward", "%l:1:%f", "%p" }
            },
            latexFormatter = "latexindent",
            latexindent = { modifyLineBreaks = false }
        }
    }
}
