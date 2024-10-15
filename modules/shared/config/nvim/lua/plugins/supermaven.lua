return {
  -- Unmap Tab and Shift-Tab in cmp and optionally in LuaSnip
  -- Fixes supermaven tab completion which was conflicting with cmp
  -- https://github.com/supermaven-inc/supermaven-nvim/issues/10#issuecomment-2143344098
  --
  -- Uncomment if LuaSnip is enabled
  -- {
  --   "L3MON4D3/LuaSnip",
  --   keys = {
  --     { "<Tab>", false, mode = { "i", "s" } },
  --     { "<S-Tab>", false, mode = { "i", "s" } },
  --   },
  -- },
  {
    "hrsh7th/nvim-cmp",
    keys = {
      { "<Tab>", false, mode = { "i", "s" } },
      { "<S-Tab>", false, mode = { "i", "s" } },
    },
  },
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },
}
