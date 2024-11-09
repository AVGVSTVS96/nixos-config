return {
  {
    "folke/flash.nvim",
    config = function()
      vim.schedule(function()
        -- FlashMatch highlight group (high contrast)
        vim.api.nvim_set_hl(0, "FlashMatch", {
          fg = "#7aa2f7",
          bold = true, -- Bold text
        })

        -- FlashCursor highlight group (high contrast)
        vim.api.nvim_set_hl(0, "FlashLabel", {
          fg = "#e1f8fa", -- Black text
          bg = "#000000", -- White background
          bold = true, -- Bold text
        })

        -- FlashCurrent highlight group (high contrast)
        vim.api.nvim_set_hl(0, "FlashCurrent", {
          fg = "#000000", -- Black text
          bg = "#FFFFFF", -- White background
          bold = true, -- Bold text
        })
      end)
    end,
  },
}
