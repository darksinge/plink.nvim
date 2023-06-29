# plink.nvim

## Introduction

A plugin to find more plugins.

**WARNING:** This plugin (like all my side projects) is a massive work in
progress, as in "pre-alpha", as in don't be surprised if it doesn't work.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- init.lua
{
    'darksinge/plink.nvim',
    commit = 'dc074d7',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'darksinge/neodash.nvim',
      'MunifTanjim/nui.nvim',
    },
}
```

## Usage

This plugin has a backend component ([darksinge/plink-nvim-site](https://github.com/darksinge/plink-nvim-site)).

### Warning
I'm only adding these instructions because I'm just about to release a video on my 
[YouTube channel](https://www.youtube.com/@ifcodingwerenatural), **but this
is likely to break without warning and I'm only human and will probably forget
to update these instructions in a timely manner and this is definitely, 100%
not how I plan on doing this in the future**.

With that said, after installing, run the following command to (hopefully) get
the search window to appear:

```
:lua require('plink.ui').open()
```

But I reiterate: you should only look at this plugin (in its current state) if
you're simply curious and want to play around. **You _will_ encounter bugs**.

## TODOs

- auto install plugins on selection
  - copy config to clipboard by default
  - set up auto install for popular dists like lunarvim, lazyvim, nvchad,
    astrovim, kickstarter.nvim, etc.
- allow sorting results by author, popularity, tags, etc.
- make UI look as pretty as humanely possible
