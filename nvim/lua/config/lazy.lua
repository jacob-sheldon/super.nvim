-- 安装 lazy.nvim（首次自动）
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  --------------------------------------------------
  -- 1. Neo-tree（文件树）
  --------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          hijack_netrw_behavior = "open_default",
        },
        window = {
          width = 32,
        },
      })

      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle filesystem left<cr>", { desc = "Toggle file tree" })
      vim.keymap.set("n", "<leader>o", "<cmd>Neotree focus filesystem left<cr>", { desc = "Focus file tree" })
      vim.keymap.set("n", "<leader>bf", "<cmd>Neotree reveal filesystem left<cr>", { desc = "Reveal current file" })
    end,
  },

  --------------------------------------------------
  -- 2. Bufferline（顶部标签栏）
  --------------------------------------------------
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          always_show_bufferline = true,
        },
      })

      vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
      vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
      vim.keymap.set("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close current buffer" })
    end,
  },

  --------------------------------------------------
  -- 3. Which-key（快捷键提示）
  --------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")

      wk.setup({
        preset = "modern",
        delay = 300,
      })

      wk.add({
        { "<leader>c", group = "command" },
        { "<leader>b", group = "buffer" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>r", group = "refactor" },
        { "<leader>cc", desc = "Tmux split + Claude" },
        { "<leader>co", desc = "Tmux split + Codex" },
        { "<leader>bf", desc = "Reveal current file" },
        { "<leader>ff", desc = "Find files" },
        { "<leader>fg", desc = "Live grep" },
        { "<leader>fb", desc = "Find buffers" },
        { "<leader>fh", desc = "Help tags" },
        { "<leader>rn", desc = "Rename symbol" },
        { "<leader>gg", desc = "Open LazyGit" },
        { "<leader>gf", desc = "LazyGit current file" },
        { "<leader>gb", desc = "Git blame line" },
        { "<leader>gp", desc = "Preview hunk" },
        { "<leader>gr", desc = "Reset hunk" },
        { "<leader>gs", desc = "Stage hunk" },
        { "<leader>x", desc = "Close current buffer" },
        { "<leader>e", desc = "Toggle file tree" },
        { "<leader>o", desc = "Focus file tree" },
      })
    end,
  },

  --------------------------------------------------
  -- 4. LazyGit（Git TUI）
  --------------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "LazyGit",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit current file" },
    },
  },

  --------------------------------------------------
  -- 5. Gitsigns（行级 Git 标记）
  --------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = false,
      })

      vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Git blame line" })
      vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview hunk" })
      vim.keymap.set("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset hunk" })
      vim.keymap.set("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", { desc = "Stage hunk" })
    end,
  },

  --------------------------------------------------
  -- 6. Telescope（搜索）
  --------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
    end,
  },

  --------------------------------------------------
  -- 7. Treesitter（语法高亮）
  --------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua", "javascript", "typescript", "tsx", "html", "css"
        },
        highlight = { enable = true },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua", "javascript", "typescript", "tsx", "html", "css" },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  --------------------------------------------------
  -- 8. LSP（语言服务）
  --------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = { "ts_ls" },
      })

      -- 通用按键
      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Find references" }))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover docs" }))
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
      end

      local servers = {
        ts_ls = { on_attach = on_attach },
      }

      if vim.fn.exepath("lua-language-server") ~= "" then
        servers.lua_ls = { on_attach = on_attach }
      end

      if vim.lsp and vim.lsp.config then
        for server, opts in pairs(servers) do
          vim.lsp.config(server, opts)
          vim.lsp.enable(server)
        end
      else
        local lspconfig = require("lspconfig")
        for server, opts in pairs(servers) do
          lspconfig[server].setup(opts)
        end
      end
    end,
  },

  --------------------------------------------------
  -- 9. nvim-cmp（自动补全）
  --------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

})
