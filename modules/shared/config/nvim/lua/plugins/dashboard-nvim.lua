return {
  "nvimdev/dashboard-nvim",
  opts = {
    theme = "hyper",
    hide = {
      statusline = false,
    },
    config = {
      shortcut = {
        {
          desc = "Find File",
          icon = " ",
          key = "f",
          action = "lua LazyVim.pick()()",
          group = "DashboardShortcut",
        },
        {
          desc = "New File",
          icon = " ",
          key = "n",
          action = "ene | startinsert",
          group = "DashboardShortcut",
        },
        {
          desc = "Recent Files",
          icon = " ",
          key = "r",
          action = 'lua LazyVim.pick("oldfiles")()',
          group = "DashboardShortcut",
        },
        {
          desc = "Find Text",
          icon = " ",
          key = "g",
          action = 'lua LazyVim.pick("live_grep")()',
          group = "DashboardShortcut",
        },
        {
          desc = "Config",
          icon = " ",
          key = "c",
          action = "lua LazyVim.pick.config_files()()",
          group = "DashboardShortcut",
        },
        {
          desc = "Restore Session",
          icon = " ",
          key = "s",
          action = 'lua require("persistence").load()',
          group = "DashboardShortcut",
        },
        {
          desc = "Lazy Extras",
          icon = " ",
          key = "x",
          action = "LazyExtras",
          group = "DashboardShortcut",
        },
        {
          desc = "Lazy",
          icon = "󰒲 ",
          key = "l",
          action = "Lazy",
          group = "DashboardShortcut",
        },
        {
          desc = "Quit",
          icon = " ",
          key = "q",
          action = function()
            vim.api.nvim_input("<cmd>qa<cr>")
          end,
          group = "DashboardShortcut",
        },
      },
      packages = {
        enable = true,
      },
      project = {
        enable = true,
        limit = 8,
        icon = "📂",
        label = "Projects",
        action = function(path)
          vim.cmd("Telescope find_files cwd=" .. path)
        end,
      },
      mru = {
        limit = 10,
        icon = "📄",
        label = "Recent Files",
        cwd_only = false,
      },
    },
  },
}
