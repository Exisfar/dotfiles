-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
          "lua",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          "python",
          "c",
          "cpp",
          "cuda",
          "go",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      "pyright",
      "clangd",
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      gopls = {
        settings = {
          gopls = {
            usePlaceholders = true,
            completeUnimported = true,
            analyses = {
              unusedparams = true,
              unusedvariable = true,
              nilness = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      },
      clangd = {
        -- mason = false,
        cmd = {
          "clangd",
          "--pretty", -- 输出的 JSON 文件更美观
          "--compile-commands-dir=${workspaceFolder}/",
          "--query-driver=/usr/bin/gcc", --指定编译器路径
          "--log=verbose", -- 让 Clangd 生成更详细的日志
          "--background-index", --后台分析并保存索引
          "--all-scopes-completion", -- 全局补全(补全建议会给出在当前作用域不可见的索引,插入后自动补充作用域标识符),例如在main()中直接写cout,即使没有`#include <iostream>`,也会给出`std::cout`的建议,配合"--header-insertion=iwyu",还可自动插入缺失的头文件
          "--clang-tidy", -- 启用 Clang-Tidy 以提供「静态检查」
          "--clang-tidy-checks=performance-*, bugprone-*, misc-*, google-*, modernize-*, readability-*, portability-*",
          "--completion-parse=auto", -- 当 clangd 准备就绪时，用它来分析建议
          "--completion-style=detailed", -- 建议风格：打包(重载函数只会给出一个建议);还可以设置为 detailed
          -- 启用配置文件(YAML格式)
          "--enable-config",
          "--fallback-style=Google", -- 默认格式化风格: 在没找到 .clang-format 文件时采用,可用的有 LLVM, Google, Chromium, Mozilla, Webkit, Microsoft, GNU
          "--function-arg-placeholders=true", -- 补全函数时，将会给参数提供占位符，键入后按 Tab 可以切换到下一占位符，乃至函数末
          "--header-insertion-decorators", -- 输入建议中，已包含头文件的项与还未包含头文件的项会以圆点加以区分
          "--header-insertion=iwyu", -- 插入建议时自动引入头文件 iwyu
          "--include-cleaner-stdlib", -- 为标准库头文件启用清理功能(不成熟!!!)
          "--pch-storage=memory", -- pch 优化的位置(Memory 或 Disk,前者会增加内存开销，但会提升性能)
          "--ranking-model=decision_forest", -- 建议的排序方案：hueristics (启发式), decision_forest (决策树)
          "-j=12", -- 同时开启的任务数量
        },
        -- 找不到编译数据库(compile_flags.json 文件)时使用的编译器选项,这样的缺陷是不能直接索引同一项目的不同文件,只能分析系统头文件、当前文件和被include的文件
        -- init_options = {
        --   fallbackFlags = {
        --     "-pedantic",
        --     "-Wall",
        --     "-Wextra",
        --     "-Wcast-align",
        --     "-Wdouble-promotion",
        --     "-Wformat=2",
        --     "-Wimplicit-fallthrough",
        --     "-Wmisleading-indentation",
        --     "-Wnon-virtual-dtor",
        --     "-Wnull-dereference",
        --     "-Wold-style-cast",
        --     "-Woverloaded-virtual",
        --     "-Wpedantic",
        --     "-Wshadow",
        --     "-Wunused",
        --     "-pthread",
        --     "-fuse-ld=lld",
        --     "-fsanitize=address",
        --     "-fsanitize=undefined",
        --     -- "-stdlib=libc++", -- 这里可以包含额外的头文件路径}
        --   },
        -- },
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
      -- function(server, opts) require("lspconfig")[server].setup(opts) end

      -- the key is the server that is being setup with `lspconfig`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
