{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      lua-language-server          # Lua (nvim config)
      nil                          # Nix
      gopls                        # Go
      typescript-language-server   # TypeScript / JavaScript
      yaml-language-server         # YAML (k8s manifests etc.)
      ripgrep                      # telescope live_grep
      fd                           # telescope file finder
    ];

    plugins = with pkgs.vimPlugins; [
      # ── Theme ──────────────────────────────────────────────────────────
      tokyonight-nvim

      # ── UI ─────────────────────────────────────────────────────────────
      lualine-nvim
      bufferline-nvim
      nvim-web-devicons
      indent-blankline-nvim

      # ── File explorer ───────────────────────────────────────────────────
      plenary-nvim
      nui-nvim
      neo-tree-nvim
      nvim-window-picker

      # ── Fuzzy finder ────────────────────────────────────────────────────
      telescope-nvim
      telescope-fzf-native-nvim

      # ── Syntax highlighting ─────────────────────────────────────────────
      nvim-treesitter.withAllGrammars

      # ── Git ─────────────────────────────────────────────────────────────
      gitsigns-nvim

      # ── LSP ─────────────────────────────────────────────────────────────
      nvim-lspconfig

      # ── Completion ──────────────────────────────────────────────────────
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip

      # ── Editing helpers ─────────────────────────────────────────────────
      comment-nvim
      nvim-autopairs
      which-key-nvim
    ];

    extraLuaConfig = ''
      -- ══════════════════════════════════════════════════════════════════
      --  Options
      -- ══════════════════════════════════════════════════════════════════
      vim.g.mapleader      = " "
      vim.g.maplocalleader = " "

      local opt = vim.opt
      opt.number         = true
      opt.relativenumber = true
      opt.signcolumn     = "yes"
      opt.cursorline     = true
      opt.scrolloff      = 8
      opt.sidescrolloff  = 8

      opt.expandtab   = true
      opt.shiftwidth  = 2
      opt.tabstop     = 2
      opt.smartindent = true

      opt.wrap      = false
      opt.linebreak = true

      opt.ignorecase = true
      opt.smartcase  = true
      opt.hlsearch   = false

      opt.splitbelow = true
      opt.splitright = true

      opt.termguicolors = true
      opt.pumheight     = 10
      opt.clipboard     = "unnamedplus"
      opt.undofile      = true
      opt.swapfile      = false
      opt.updatetime    = 200
      opt.timeoutlen    = 300

      -- ══════════════════════════════════════════════════════════════════
      --  Theme: Tokyo Night Moon
      -- ══════════════════════════════════════════════════════════════════
      require("tokyonight").setup({
        style           = "moon",
        transparent     = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
        sidebars = { "neo-tree", "qf", "help", "terminal" },
        on_highlights = function(hl, c)
          hl.CursorLineNr = { fg = c.orange, bold = true }
          hl.LineNr       = { fg = c.comment }
        end,
      })
      vim.cmd.colorscheme("tokyonight-moon")

      -- ══════════════════════════════════════════════════════════════════
      --  Statusline: Lualine
      -- ══════════════════════════════════════════════════════════════════
      require("lualine").setup({
        options = {
          theme                = "tokyonight",
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          globalstatus         = true,
        },
        sections = {
          lualine_a = { { "mode" } },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })

      -- ══════════════════════════════════════════════════════════════════
      --  Buffer tabline: Bufferline
      -- ══════════════════════════════════════════════════════════════════
      require("bufferline").setup({
        options = {
          mode                    = "buffers",
          separator_style         = "slant",
          always_show_bufferline  = true,
          show_buffer_close_icons = true,
          show_close_icon         = false,
          diagnostics             = "nvim_lsp",
          offsets = {
            {
              filetype   = "neo-tree",
              text       = "  Explorer",
              text_align = "center",
              separator  = true,
            },
          },
        },
      })

      -- ══════════════════════════════════════════════════════════════════
      --  Indent guides: indent-blankline v3
      -- ══════════════════════════════════════════════════════════════════
      require("ibl").setup({
        indent = { char = "│" },
        scope  = { enabled = true, show_start = true },
      })

      -- ══════════════════════════════════════════════════════════════════
      --  File explorer: Neo-tree
      -- ══════════════════════════════════════════════════════════════════
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style   = "rounded",
        window = {
          width    = 30,
          mappings = { ["<space>"] = "none" },
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles   = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = true },
        },
        default_component_configs = {
          git_status = {
            symbols = {
              added     = "",
              modified  = "",
              deleted   = "✖",
              renamed   = "󰁕",
              untracked = "",
              ignored   = "",
              unstaged  = "󰄱",
              staged    = "",
              conflict  = "",
            },
          },
        },
      })

      -- ══════════════════════════════════════════════════════════════════
      --  Fuzzy finder: Telescope
      -- ══════════════════════════════════════════════════════════════════
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix   = "   ",
          selection_caret = " ",
          path_display    = { "truncate" },
          border          = true,
          borderchars     = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = { hidden = true },
          live_grep  = { additional_args = { "--hidden" } },
        },
      })
      telescope.load_extension("fzf")

      -- ══════════════════════════════════════════════════════════════════
      --  Syntax: Treesitter (0.10+ API)
      --  require("nvim-treesitter.configs") は 0.10 で廃止。
      --  パーサーが rtp に入っていれば FileType 時に vim.treesitter.start() で有効化。
      -- ══════════════════════════════════════════════════════════════════
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ok = pcall(vim.treesitter.start, args.buf)
          if ok then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- ══════════════════════════════════════════════════════════════════
      --  Git: Gitsigns
      -- ══════════════════════════════════════════════════════════════════
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        current_line_blame = false,
      })

      -- ══════════════════════════════════════════════════════════════════
      --  LSP (nvim 0.11 / lspconfig v3 API)
      --  require('lspconfig').xxx.setup() は廃止 → vim.lsp.config + enable
      -- ══════════════════════════════════════════════════════════════════

      -- cmp の補完能力を全サーバーに適用
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- lua_ls のみ個別設定（vim グローバルを認識させる）
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      -- サーバーを有効化（lspconfig が rtp にあれば自動でデフォルト設定を提供）
      vim.lsp.enable({ "lua_ls", "nil_ls", "gopls", "ts_ls", "yamlls" })

      -- バッファアタッチ時のキーマップ
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = args.buf, desc = desc })
          end
          map("gd",         vim.lsp.buf.definition,                              "Go to Definition")
          map("gD",         vim.lsp.buf.declaration,                             "Go to Declaration")
          map("gr",         vim.lsp.buf.references,                              "References")
          map("gi",         vim.lsp.buf.implementation,                          "Go to Implementation")
          map("K",          vim.lsp.buf.hover,                                   "Hover Docs")
          map("<leader>ca", vim.lsp.buf.code_action,                             "Code Action")
          map("<leader>rn", vim.lsp.buf.rename,                                  "Rename Symbol")
          map("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
        end,
      })

      vim.diagnostic.config({
        virtual_text  = { prefix = "●" },
        severity_sort = true,
        float         = { border = "rounded" },
      })

      -- ══════════════════════════════════════════════════════════════════
      --  Completion: nvim-cmp
      -- ══════════════════════════════════════════════════════════════════
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = function(_, item)
            local icons = {
              Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
              Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
              Module = "", Property = "󰜢", Keyword = "󰌋", Snippet = "",
              Color = "󰏘", File = "󰈙", Folder = "󰉋", EnumMember = "",
              Constant = "󰏿", Struct = "󰙅", Value = "󰎠", Enum = "",
              Unit = "", Event = "", Operator = "󰆕", TypeParameter = "󰅲", Reference = "",
            }
            item.kind = string.format("%s %s", icons[item.kind] or "?", item.kind)
            return item
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-d>"]     = cmp.mapping.scroll_docs(4),
          ["<C-u>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- ══════════════════════════════════════════════════════════════════
      --  Editing helpers
      -- ══════════════════════════════════════════════════════════════════
      require("Comment").setup()
      require("nvim-autopairs").setup({ check_ts = true })

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      require("which-key").setup({ icons = { mappings = true } })

      -- ══════════════════════════════════════════════════════════════════
      --  Keymaps
      -- ══════════════════════════════════════════════════════════════════
      local map = vim.keymap.set

      -- ペイン移動（tmux の hjkl に合わせる）
      map("n", "<C-h>", "<C-w>h", { desc = "Pane left" })
      map("n", "<C-j>", "<C-w>j", { desc = "Pane down" })
      map("n", "<C-k>", "<C-w>k", { desc = "Pane up" })
      map("n", "<C-l>", "<C-w>l", { desc = "Pane right" })

      -- バッファ移動
      map("n", "<S-h>",      ":bprevious<CR>", { desc = "Prev buffer",   silent = true })
      map("n", "<S-l>",      ":bnext<CR>",     { desc = "Next buffer",   silent = true })
      map("n", "<leader>bd", ":bdelete<CR>",   { desc = "Delete buffer", silent = true })

      -- ファイルエクスプローラー
      map("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle explorer", silent = true })
      map("n", "<leader>o", ":Neotree focus<CR>",  { desc = "Focus explorer",  silent = true })

      -- Telescope
      local builtin = require("telescope.builtin")
      map("n", "<C-p>",      builtin.find_files,                { desc = "Find files" })
      map("n", "<leader>ff", builtin.find_files,                { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep,                 { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers,                   { desc = "Buffers" })
      map("n", "<leader>fh", builtin.help_tags,                 { desc = "Help tags" })
      map("n", "<leader>fr", builtin.oldfiles,                  { desc = "Recent files" })
      map("n", "<leader>fs", builtin.lsp_document_symbols,      { desc = "Symbols" })
      map("n", "<leader>fd", builtin.diagnostics,               { desc = "Diagnostics" })
      map("n", "<leader>/",  builtin.current_buffer_fuzzy_find, { desc = "Search in buffer" })

      -- Diagnostics
      map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Diagnostic float" })
      map("n", "[d",        vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
      map("n", "]d",        vim.diagnostic.goto_next,  { desc = "Next diagnostic" })

      -- Git (gitsigns)
      map("n", "<leader>gb", ":Gitsigns blame_line<CR>",   { desc = "Git blame",    silent = true })
      map("n", "<leader>gd", ":Gitsigns diffthis<CR>",     { desc = "Git diff",     silent = true })
      map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Preview hunk", silent = true })
      map("n", "]h",         ":Gitsigns next_hunk<CR>",    { desc = "Next hunk",    silent = true })
      map("n", "[h",         ":Gitsigns prev_hunk<CR>",    { desc = "Prev hunk",    silent = true })

      -- 雑多
      map("n", "<leader>w", ":w<CR>",          { desc = "Save",         silent = true })
      map("n", "<leader>q", ":q<CR>",          { desc = "Quit",         silent = true })
      map("n", "<Esc>",     ":nohlsearch<CR>", { desc = "Clear search", silent = true })
    '';
  };
}
