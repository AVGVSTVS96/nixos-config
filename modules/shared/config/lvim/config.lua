-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Whichkey timeout
vim.opt.timeoutlen = 50

-- Allow capital Q to quit
vim.cmd("command! Q q")

-- Autosave
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = { "*" },
  command = "silent! wall",
  nested = true,
})

-- Plugins
lvim.plugins = {
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  }
}

-- Override Edit config.lua mappings in alpha and whichkey to nixos-config location
lvim.builtin.which_key.mappings.L.c[1] = "<CMD>edit ~/nixos-config/modules/shared/config/lvim/config.lua <CR>"
lvim.builtin.alpha.dashboard.section.buttons.entries[6][3] = "<CMD>edit ~/nixos-config/modules/shared/config/lvim/config.lua <CR>"
