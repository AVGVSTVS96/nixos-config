-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local cmd = vim.cmd

cmd("cabbrev Q q")

-- Map Page Up and Down to behave like Ctrl-D and Ctrl-U
map("n", "<PageDown>", "<C-d>", { noremap = true, silent = true })
map("n", "<PageUp>", "<C-u>", { noremap = true, silent = true })

-- Map 'U' to redo
map("n", "U", ":redo<CR>", { noremap = true, silent = true })

-- Map <A-Up> and <A-Down> to move up and down
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move Up" })

-- map <C-y> to yank to system register
map("n", "<C-y>", '"+y', { noremap = true, silent = true, desc = "Yank to system register" })
map("v", "<C-y>", '"+y', { noremap = true, silent = true, desc = "Yank to system register" })

-- Map bufferline tab picker
map("n", "<leader>bs", ":BufferLinePick<CR>", { silent = true, desc = "Pick buffer" })
