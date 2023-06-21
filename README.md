# plink.nvim

## Introduction

A plugin to find more plugins.

**WARNING:** This plugin (like all my side projects) is a massive work in
progress, as in "pre-alpha", as in don't be surprised if it doesn't work.

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'darksinge/plink.nvim',
  requires = { {'nvim-lua/plenary.nvim'} }
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- init.lua
{
    'darksinge/plink.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim'
    },
}
```

## Usage

This plugin has a backend component ([darksinge/plink-nvim-site](https://github.com/darksinge/plink-nvim-site)).

## TODOs

- add telescope extension
  - also, ask yourself, is telescope the right tool for this? Part of me thinks
    no...
- auto install plugins on selection
  - copy config to clipboard by default
  - set up auto install for popular dists like lunarvim, lazyvim, nvchad,
    astrovim, kickstarter.nvim, etc.
- allow sorting results by author, popularity, tags, etc.
- cache results locally
