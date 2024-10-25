return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      vim.cmd([[highlight WinSeparator guifg=#3C3F47]])
      return opts
    end,
  },
}
