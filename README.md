<div align='center'>
  <img width='200' src='docs/neovim-nekologo.png'/>

  # <samp>[NekoVim](https://github.com/pandasoli/nekovim)</samp>
  Discord [Rich Presence](https://discord.com/rich-presence) plugin for [Neovim](https://neovim.io)

  <br/>
  <img src='https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png' width='600'/>

  <br/>
  <div align='center'>

  ![Number of issues](https://img.shields.io/github/issues/pandasoli/nekovim?color=fab387&labelColor=303446&style=for-the-badge)
  ![Number of stars](https://img.shields.io/github/stars/pandasoli/nekovim?color=ed8796&labelColor=303446&style=for-the-badge)
  [![MIT license](https://img.shields.io/github/license/pandasoli/nekovim?style=for-the-badge&label=License&labelColor=313244&color=ca9ee6)](LICENSE)

  ![Supports Linux](https://img.shields.io/badge/Linux-%23.svg?style=for-the-badge&logo=linux&logoColor=eed49f&label=support&labelColor=303446&color=eed49f)
  ![Supports Windows](https://img.shields.io/badge/Windows-%23.svg?style=for-the-badge&label=support&labelColor=303446&color=7dc4e4)
  </div>
</div>

<br/>
<br/>

## Features <img width=20 src='https://svgrepo.com/show/407500/sparkles.svg'/>

- Fast
- No dependencies
- Auto presence update
- Multiple instances
- Really highly configurable

  > The only thing you "cannot change" is the text “Playing **Neovim**”.  
  > Actually, you can! But it would require [changing the Discord bot](./docs/work_props.md).

<br/>
<br/>
<div align='right'>

  ## <img width=20 src='https://svgrepo.com/show/406033/laptop.svg'/> Requirements
</div>

I didn't fully tested, but I made with the following versions.  
If any bug occur, please let me know.

<br/>

- NVIM `v0.9.2`  
  LuaJIT `2.1.1693350652`

<br/>
<br/>

## Installation <img width=20 src='https://svgrepo.com/show/406828/package.svg'/>

Add this repo (`pandasoli/nekovim`) to your plugins list.

> [!NOTE]
> Multi-instance does _not_ work on Windows yet.  
> It should be working but for some reason it's not, I'm accepting pull requests.

<br/>
<br/>
<div align='right'>

## <img width=20 src='https://svgrepo.com/show/405718/gear.svg'/> Configuration
</div>

The `Nekovim.setup` function is used to set up the plugin.  
If you don't configure, it's gonna use [the default config](./lua/default_makers/init.lua).

<br/>
<div align='center'>
  <img src='./docs/empty-preview.gif'/>
  <img src='./docs/final-preview.gif'/>
</div>
<br/>

```lua
---@type func(PresenceMakers, WorkPropsMakers)
require 'nekovim'.setup {}
```

More info about **Presence Makers** in [Presence Table](./docs/presence_table.md).  
I explain more about **Work Props** in [Work Props](./docs/work_props.md).

<br/>
<br/>

## Development <img width=20 src='https://svgrepo.com/show/407587/technologist.svg'/>

Before creating a pull request, read the [docs for developers](./DEVELOPMENT.md) <img width=16 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/2615.svg'/>  
We have also [some tasks to be done](./docs/todo.md) if you would like to help <img width=16 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f389.svg'/>

<br/>

I didn't know anything about creating a plugin before having troubles with other rich presence plugins.  
I'd like to thank [andweeb/presence.nvim](https://github.com/andweeb/presence.nvim), their code helped me a lot developing **NekoVim**.
