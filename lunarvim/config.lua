--[[
lvim is the global options object

Linters should be
filled in as strings with either
a global executable or a path to
an executable
]] -- THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
-- general
-- set tab as 4
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

lvim.log.level = "warn"

-- format on save
lvim.format_on_save = false

-- colorscheme
lvim.colorscheme = "monokai_ristretto"

-- background transparent
lvim.transparent_window = false

-- error info
lvim.lsp.diagnostics.virtual_text = false

-- enable dap
lvim.builtin.dap.active = true
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false 

-- keymappings [view all the defaults by pressing <leader>Lk]
lvim.leader = "space"

-- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>" -- save
lvim.keys.normal_mode["<C-z>"] = ":undo<cr>" -- undo
lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>" -- next buffer
lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>" -- last buffer

-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
-- override a default keymapping
lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- Change Telescope navigation to use j and k for navigation and n and p for history in both input and normal mode.
-- we use protected-mode (pcall) just in case the plugin wasn't loaded yet.
-- local _, actions = pcall(require, "telescope.actions")
-- lvim.builtin.telescope.defaults.mappings = {
--   -- for input mode
--   i = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous,
--     ["<C-n>"] = actions.cycle_history_next,
--     ["<C-p>"] = actions.cycle_history_prev
--   },
--   -- for normal mode
--   n = {
--     ["<C-j>"] = actions.move_selection_next,
--     ["<C-k>"] = actions.move_selection_previous
--   }
-- }

-- Use which-key to add extra bindings with the leader-key prefix
lvim.builtin.which_key.mappings["P"] = {
    "<cmd>Telescope projects<CR>", "Projects"
}

lvim.builtin.which_key.mappings["t"] = {
    name = "+Trouble",
    r = {"<cmd>Trouble lsp_references<cr>", "References"},
    f = {"<cmd>Trouble lsp_definitions<cr>", "Definitions"},
    d = {"<cmd>Trouble document_diagnostics<cr>", "Diagnostics"},
    q = {"<cmd>Trouble quickfix<cr>", "QuickFix"},
    l = {"<cmd>Trouble loclist<cr>", "LocationList"},
    w = {"<cmd>Trouble lsp_workspace_diagnostics<cr>", "Workspace Diagnostics"}
}

-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.notify.active = true
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.builtin.telescope.defaults.path_display = {"smart"}

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
    "bash", "c", "javascript", "json", "lua", "python", "typescript", "tsx",
    "css", "rust", "java", "yaml"
}
lvim.builtin.treesitter.ignore_install = {"haskell"}
lvim.builtin.treesitter.highlight.enabled = true
lvim.builtin.treesitter.autotag.enable = true

local opts = {}
local formatters = require "lvim.lsp.null-ls.formatters"
local linters = require "lvim.lsp.null-ls.linters"

-- C/Cpp
require("lvim.lsp.manager").setup("clangd", opts)
formatters.setup {{exe = "uncrustify", args = {}, filetypes = {"cpp", "c"}}}

linters.setup {
    {command = "cpplint", filetypes = {"cpp", "c"}}, {command = "codespell"}
}

local clangd_flags = {
    "--all-scopes-completion", "--suggest-missing-includes",
    "--background-index", "--pch-storage=disk", "--cross-file-rename",
    "--log=info", "--completion-style=detailed", "--enable-config", -- clangd 11+ supports reading from .clangd configuration file
    "--clang-tidy",
    "clang-tidy-checks=-*,llvm-*,clang-analyzer-*,modernize-*,-modernize-use-trailing-return-type",
    "fallback-style=Google", "header-insertion=never",
    "query-driver=<list-of-white-listed-complers>"
}

local clangd_bin = "clangd"

local custom_on_attach = function(client, bufnr)
    require("lvim.lsp").common_on_attach(client, bufnr)
    local opts = {noremap = true, silent = true}
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>lh",
                                "<Cmd>ClangdSwitchSourceHeader<CR>", opts)
end

local opts = {
    cmd = {clangd_bin, unpack(clangd_flags)},
    on_attach = custom_on_attach
}

local dap = require('dap')
dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
    name = 'lldb'
}

dap.configurations.cpp = {
    {
        name = 'Launch',
        type = 'lldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/',
                                'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {}

        -- 💀
        -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
        --
        --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        --
        -- Otherwise you might get the following error:
        --
        --    Error on launch: Failed to attach to the target process
        --
        -- But you should be aware of the implications:
        -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
        -- runInTerminal = false,
    }
}

-- If you want to use this for Rust and C, add something like this:

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- rust
require("lvim.lsp.manager").setup("rust_analyzer", opts)
formatters.setup {{command = "rustfmt", filetypes = {"rust"}}}

lvim.plugins = {
    {
        "simrat39/rust-tools.nvim",
        -- ft = { "rust", "rs" }, -- IMPORTANT: re-enabling this seems to break inlay-hints
        config = function()
            require("rust-tools").setup {
                tools = {
                    executor = require("rust-tools/executors").termopen, -- can be quickfix or termopen
                    reload_workspace_from_cargo_toml = true,
                    inlay_hints = {
                        auto = true,
                        only_current_line = false,
                        show_parameter_hints = true,
                        parameter_hints_prefix = "<-",
                        other_hints_prefix = "=>",
                        max_len_align = false,
                        max_len_align_padding = 1,
                        right_align = false,
                        right_align_padding = 7,
                        highlight = "Comment"
                    },
                    hover_actions = {
                        border = {
                            {"╭", "FloatBorder"}, {"─", "FloatBorder"},
                            {"╮", "FloatBorder"}, {"│", "FloatBorder"},
                            {"╯", "FloatBorder"}, {"─", "FloatBorder"},
                            {"╰", "FloatBorder"}, {"│", "FloatBorder"}
                        },
                        auto_focus = true
                    }
                },
                server = {
                    on_init = require("lvim.lsp").common_on_init,
                    on_attach = function(client, bufnr)
                        require("lvim.lsp").common_on_attach(client, bufnr)
                        local rt = require "rust-tools"
                        -- Hover actions
                        vim.keymap.set("n", "<C-space>",
                                       rt.hover_actions.hover_actions,
                                       {buffer = bufnr})
                        -- Code action groups
                        vim.keymap.set("n", "<leader>lA",
                                       rt.code_action_group.code_action_group,
                                       {buffer = bufnr})
                    end
                }
            }
        end
    }
}

-- go
require("lvim.lsp.manager").setup("gopls", opts)
formatters.setup {{command = "goimports-reviser", filetypes = {"go"}}}

linters.setup {{command = "golangci-lint", filetypes = {"go"}}}

dap.adapters.go = {
    type = 'executable',
    command = 'node',
    args = {os.getenv('HOME') .. '/vscode-go/dist/debugAdapter.js'} -- specify the path to the adapter
}
dap.configurations.go = {
    {
        type = "go",
        name = "Attach",
        request = "attach",
        processId = require("dap.utils").pick_process,
        program = "${workspaceFolder}",
        dlvToolPath = vim.fn.exepath('dlv')
    }, {
        type = "go",
        name = "Debug curr file",
        request = "launch",
        program = "${file}",
        dlvToolPath = vim.fn.exepath('dlv')
    }, {
        type = "go",
        name = "Debug",
        request = "launch",
        program = "${workspaceFolder}",
        dlvToolPath = vim.fn.exepath('dlv')
    }, {
        type = "go",
        name = "Debug curr test",
        request = "launch",
        mode = "test",
        program = "${file}",
        dlvToolPath = vim.fn.exepath('dlv')
    }, {
        type = "go",
        name = "Debug test",
        request = "launch",
        mode = "test",
        program = "${workspaceFolder}",
        dlvToolPath = vim.fn.exepath('dlv')
    }
}

-- python
require("lvim.lsp.manager").setup("pyright", opts)
formatters.setup {{command = "black", filetypes = {"python"}}}
linters.setup {{command = "flake8", filetypes = {"python"}}}

-- lua
require("lvim.lsp.manager").setup("sumneko_lua", opts)
formatters.setup {{command = "lua-format", filetypes = {"lua"}}}
linters.setup {{command = "luacheck", filetypes = {"lua"}}}

-- html
require("lvim.lsp.manager").setup("html", opts)
formatters.setup {{command = "prettier", filetypes = {"html"}}}
-- linters.setup {
--     { command = "erb-lint", filetypes = { "html" } }
-- }

-- xml
require("lvim.lsp.manager").setup("lemminx", opts)

-- css
require("lvim.lsp.manager").setup("cssls", opts)
formatters.setup {{command = "prettier_d_slim", filetypes = {"css"}}}

-- js/ts
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "tsserver" })
-- require("lvim.lsp.manager").setup("denols", opts)
formatters.setup {
    {command = "eslint", filetypes = {"javascript", "typescript"}}
}
linters.setup {{command = "eslint_d", filetypes = {"javascript", "typescript"}}}

-- bash
require("lvim.lsp.manager").setup("bashls", opts)
formatters.setup {{command = "shfmt", filetypes = {"bash"}}}
linters.setup {{command = "shellcheck", filetypes = {"bash"}}}

-- vue
require("lvim.lsp.manager").setup("vls", opts)
formatters.setup {{command = "prettier_d_slim", filetypes = {"vue"}}}
linters.setup {{command = "eslint", filetypes = {"vue"}}}

-- json
require("lvim.lsp.manager").setup("jsonls", opts)
formatters.setup {{command = "fixjson", filetypes = {"json"}}}
linters.setup {{command = "cfn-lint", filetypes = {"json"}}}

-- cmake
require("lvim.lsp.manager").setup("cmake", opts)
formatters.setup {{command = "cmake_format", filetypes = {"cmake"}}}

-- toml
-- require("lvim.lsp.manager").setup("toml", opts)

-- sql
require("lvim.lsp.manager").setup("sqlls", opts)
formatters.setup {{command = "sql-formatter", filetypes = {"sql"}}}
-- linters.setup {
--     { command = "sqlfluff", filetypes = { "sql" } }
-- }

-- vimscript
require("lvim.lsp.manager").setup("vimls", opts)
linters.setup {{command = "vint", filetypes = {"vimscript"}}}

-- java
require("lvim.lsp.manager").setup("jdtls", opts)
formatters.setup {{command = "cmake_format", filetypes = {"java"}}}

-- ruby
require("lvim.lsp.manager").setup("solargraph", opts)
formatters.setup {{command = "rubocop", filetypes = {"ruby"}}}
linters.setup {{command = "standardrb", filetypes = {"ruby"}}}

-- c_sharp
require("lvim.lsp.manager").setup("omnisharp", opts)
formatters.setup {{command = "clang-format", filetypes = {"c_sharp"}}}

-- julia
require("lvim.lsp.manager").setup("julials", opts)

-- kotlin
require("lvim.lsp.manager").setup("kotlin_language_server", opts)
linters.setup {{command = "ktlint", filetypes = {"kotlin"}}}

-- docker file
require("lvim.lsp.manager").setup("dockerls", opts)
linters.setup {{command = "hadolint", filetypes = {"dockerfile"}}}

-- django
formatters.setup {{command = "djlint", filetypes = {"django"}}}
linters.setup {{command = "curlylint", filetypes = {"django"}}}

-- awk
require("lvim.lsp.manager").setup("awk_ls", opts)

-- yaml
require("lvim.lsp.manager").setup("yamlls", opts)
formatters.setup {{command = "yamlfmt", filetypes = {"yaml"}}}
linters.setup {{command = "yamllint", filetypes = {"yaml"}}}

-- lvim.lsp.installer.setup.automatic_installation = true

-- generic LSP settings

-- -- make sure server will always be installed even if the server is in skipped_servers list
-- lvim.lsp.installer.setup.ensure_installed = {
--     "sumeko_lua",
--     "jsonls",
-- }
-- -- change UI setting of `LspInstallInfo`
-- -- see <https://github.com/williamboman/nvim-lsp-installer#default-configuration>
-- lvim.lsp.installer.setup.ui.check_outdated_servers_on_open = false
-- lvim.lsp.installer.setup.ui.border = "rounded"
-- lvim.lsp.installer.setup.ui.keymaps = {
--     uninstall_server = "d",
--     toggle_server_expand = "o",
-- }

-- ---@usage disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- set a formatter, this will override the language server formatting capabilities (if it exists)
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "black", filetypes = { "python" } },
--   { command = "isort", filetypes = { "python" } },
--   {
--     -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "prettier",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--print-with", "100" },
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }

-- -- set additional linters
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--     command = "shellcheck",
--     ---@usage arguments to pass to the formatter
--     -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--     extra_args = { "--severity", "warning" },
--   },
--   {
--     command = "codespell",
--     ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--     filetypes = { "javascript", "python" },
--   },
-- }

-- Additional Plugins
lvim.plugins = {
    {"folke/tokyonight.nvim"}, {"rebelot/kanagawa.nvim"},
    {"marko-cerovac/material.nvim"}, {"sainnhe/sonokai"}, {"sainnhe/edge"},
    {"shaunsingh/moonlight.nvim"}, {"tanvirtin/monokai.nvim"},
    {"navarasu/onedark.nvim"}, {"sainnhe/gruvbox-material"},
    {"sainnhe/everforest"}, {"Mofiqul/dracula.nvim"},
    {"nxvu699134/vn-night.nvim"}, {"projekt0n/github-nvim-theme"},
    {"EdenEast/nightfox.nvim"}, {"olimorris/onedarkpro.nvim"},
    {"rmehri01/onenord.nvim"}, {"LunarVim/synthwave84.nvim"},
    {"folke/trouble.nvim", cmd = "TroubleToggle"}
}

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = { "*.json", "*.jsonc" },
--   -- enable wrap mode for json files only
--   command = "setlocal wrap",
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
-- })
