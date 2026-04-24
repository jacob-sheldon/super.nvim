vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.autoread = true

local function tmux_split_run(cmd)
  if not vim.env.TMUX or vim.env.TMUX == "" then
    vim.notify("当前不在 tmux 会话里", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable(cmd) ~= 1 then
    vim.notify("找不到命令: " .. cmd, vim.log.levels.ERROR)
    return
  end

  -- -h: 左右分屏（通常叫垂直分屏）
  vim.fn.jobstart({ "tmux", "split-window", "-h", "-c", "#{pane_current_path}", cmd }, { detach = true })
end

vim.keymap.set("n", "<leader>cc", function()
  tmux_split_run("claude")
end, { desc = "Tmux split + Claude", silent = true })

vim.keymap.set("n", "<leader>co", function()
  tmux_split_run("codex")
end, { desc = "Tmux split + Codex", silent = true })

-- 外部进程（例如 Codex）改动文件后，回到 nvim 时自动检查并刷新 buffer
local auto_checktime = vim.api.nvim_create_augroup("AutoChecktime", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose", "TermLeave" }, {
  group = auto_checktime,
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = auto_checktime,
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
})

vim.cmd("syntax enable")

vim.filetype.add({
  extension = {
    mpx = "html",
  },
})

-- 加载 lazy
require("config.lazy")
