vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

local status_ok, packer = pcall(require, 'packer')
if not status_ok then
  print('Packer failed. No plugin loaded')
  return
end

packer.init {
  display = {
    open_fn = function()
      return require('packer.util').float { border = 'rounded', style = 'minimal' }
    end,
  },
}

return packer.startup(function()

  -- use 'wbthomason/packer.nvim'
  -- use 'nvim-lua/popup.nvim'
  -- use 'nvim-lua/plenary.nvim'
  -- use 'dracula/vim'
  -- use 'mrjones2014/smart-splits.nvim'
  -- use 'numToStr/Comment.nvim'
  -- use 'kyazdani42/nvim-web-devicons'
  -- use 'kyazdani42/nvim-tree.lua'
  -- use "akinsho/bufferline.nvim"
  -- use "moll/vim-bbye"
  -- use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons' } }
  -- use { "akinsho/toggleterm.nvim", tag = 'v1.*' }

  -- Auto completion
  -- use 'hrsh7th/nvim-cmp' -- The completion plugin
  -- use 'hrsh7th/cmp-nvim-lsp'
  -- use 'hrsh7th/cmp-nvim-lua'
  -- use 'hrsh7th/cmp-buffer'
  -- use 'hrsh7th/cmp-path'
  -- use 'hrsh7th/cmp-cmdline'
  -- use 'saadparwaiz1/cmp_luasnip'

  -- snippets
  -- use 'L3MON4D3/LuaSnip' --snippet engine
  -- use 'rafamadriz/friendly-snippets' -- a bunch of snippets to use

  -- use { "neovim/nvim-lspconfig", requires = { "kyazdani42/nvim-tree.lua" } } -- enable LSP
  -- use "williamboman/nvim-lsp-installer" -- simple to use language server installer
  -- use 'JoosepAlviste/nvim-ts-context-commentstring'


  -- use "nvim-telescope/telescope.nvim"
  --use "nvim-telescope/telescope-media-files.nvim"

  -- use {
  --   "nvim-treesitter/nvim-treesitter",
  --   run = ":TSUpdate",
  -- }
  -- use { "p00f/nvim-ts-rainbow", "nvim-treesitter/playground", requires = { "nvim-treesitter/nvim-treesitter" } }

end)
