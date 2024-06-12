-- NOTE: This will get the OS from Lua:
-- print(vim.loop.os_uname().sysname)

-- setup lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- hack to deal with bug in telescope-cheat.nvim
-- https://github.com/nvim-telescope/telescope-cheat.nvim/issues/7
local cheat_dbdir = vim.fn.stdpath "data" .. "/databases"
if not vim.loop.fs_stat(cheat_dbdir) then
  vim.loop.fs_mkdir(cheat_dbdir, 493)
end

-- load additional settings
require("vim-options")
require("lazy").setup({
  { import = "plugins" },
  checker = {
    -- do not automatically check for plugin updates
    enabled = false,
  },
  install = {
    -- don't install missing plugins on startup... install them with Nix.
    missing = false,
  },
})

-- tell sqlite.lua where to find the bits it needs
vim.g.sqlite_clib_path = '${pkgs.sqlite.out}/lib/${sqlite_lib}'
