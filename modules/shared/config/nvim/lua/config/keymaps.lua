-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.cmd("command! Q q")

-- Map Page Up and Down to behave like Ctrl-D and Ctrl-U
vim.keymap.set("n", "<PageDown>", "<C-d>", { noremap = true, silent = true })
vim.keymap.set("n", "<PageUp>", "<C-u>", { noremap = true, silent = true })

-- Remap 'U' to redo
vim.api.nvim_set_keymap("n", "U", ":redo<CR>", { noremap = true, silent = true })
