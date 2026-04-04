return { 
  'nvim-treesitter/nvim-treesitter',
  lazy = false, 
  build = ':TSUpdate',
  config = function()
    local config = require("nvim-treesitter.config")
    config.setup({
      ensure_installed = { "lua", "javascript", "java" },
      highlight = { enable = true }, 
      indent = { enable = true },
    })
  end
}
