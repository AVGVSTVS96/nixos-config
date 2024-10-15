return {
  "goolord/alpha-nvim",
  event = "BufWinEnter",
  config = function()
    local alpha = require("alpha")
    local theta = require("alpha.themes.theta")
    local dashboard = require("alpha.themes.dashboard")
    local logo = [[
         ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
         ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
         ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
         ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
         ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
         ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
    ]]
    theta.header.val = vim.split(logo, "\n")

    -- Define buttons with highlight groups directly
    local function create_button(key, label, command)
      local btn = dashboard.button(key, label, command)
      btn.opts = btn.opts or {}
      btn.opts.hl = "AlphaButtons"
      btn.opts.hl_shortcut = "AlphaShortcut"
      return btn
    end

    theta.buttons.val = {
      create_button("f", "  Find File", "<cmd>lua LazyVim.pick()()<cr>"),
      { type = "padding", val = 1 },
      create_button("n", "  New File", "<cmd>ene | startinsert<cr>"),
      { type = "padding", val = 1 },
      create_button("r", "  Recent Files", "<cmd>lua LazyVim.pick('oldfiles')()<cr>"),
      { type = "padding", val = 1 },
      -- create_button("p", "  Projects", "<cmd>Telescope projects<cr>"),
      -- { type = "padding", val = 1 },
      create_button("g", "  Find Text", "<cmd>lua LazyVim.pick('live_grep')()<cr>"),
      { type = "padding", val = 1 },
      create_button("c", "  Config", "<cmd>lua LazyVim.pick.config_files()()<cr>"),
      { type = "padding", val = 1 },
      create_button("S", "  Select Session", "<cmd>lua require('persistence').select()<cr>"),
      { type = "padding", val = 1 },
      create_button("s", "  Restore Session", "<cmd>lua require('persistence').load()<cr>"),
      { type = "padding", val = 1 },
      create_button("x", "  Lazy Extras", "<cmd>LazyExtras<cr>"),
      { type = "padding", val = 1 },
      create_button("l", "󰒲  Lazy", "<cmd>Lazy<cr>"),
      { type = "padding", val = 1 },
      create_button("q", "  Quit", "<cmd>qa<cr>"),
    }

    theta.footer = {
      type = "text",
      val = "",
      opts = {
        position = "center",
        hl = "AlphaFooter",
      },
    }

    theta.header.opts.hl = "AlphaHeader"
    theta.footer.opts.hl = "AlphaFooter"

    theta.config.layout = {
      { type = "padding", val = 10 },
      theta.header,
      { type = "padding", val = 2 },
      theta.mru(0, vim.fn.getcwd(), 10),
      { type = "padding", val = 2 },
      theta.buttons,
      { type = "padding", val = 2 },
      theta.footer,
    }

    alpha.setup(theta.config)

    vim.api.nvim_create_autocmd("User", {
      once = true,
      pattern = "LazyVimStarted",
      callback = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        theta.footer.val = "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
        pcall(vim.cmd.AlphaRedraw)
      end,
    })
  end,
}
