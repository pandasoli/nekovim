<img height=150 align='right' src='./docs/undraw_welcome_cats_thqn.svg'/>

# Neko[Vim](https://vim.org) <img width=32 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f408.svg'/> <img width=32 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2728.svg'/> <img width=32 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f312.svg'/>

<div align='center'>

  > Discord [Rich Presence](https://discord.com/rich-presence) plugin for [Neovim](https://neovim.io)

  ![Linux](https://img.shields.io/badge/Linux-%23.svg?logo=linux&color=FCC624&logoColor=black)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

  <br/>

  [**Features**](#features-) | [**Instalation**](#-installation) |
  [**Configuration**](#configuration-) | [**Development**](#-development)
</div>
<br/>
<br/>

## Features <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2728.svg'/>

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

  ## <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f4e6.svg'/> Installation
</div>

Add this repo (`pandasoli/nekovim`) to your plugins list.

<br/>
<br/>

## Configuration <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2699.svg'/>
The function `Nekovim:setup` is used to set up the plugin.  
If you don't configure it'll start with [a default config](./lua/default_makers/init.lua).

<br/>
<div align='center'>
  <img src='./docs/preview.gif'/>
</div>
<br/>

```lua
---@type func(PresenceMakers, WorkPropsMakers)
require 'Nekovim':setup {}
```

More info about **Presence Makers** in [Presence Table](./docs/presence_table.md).  
I explain more about **Work Props** in [Work Props](./docs/work_props.md).

<br/>
<br/>
<div align='right'>

  ## <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f9d1-200d-1f4bb.svg'/> Development
</div>

Before creating a pull request, read the [docs for developers](./DEVELOPMENT.md) <img width=16 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2615.svg'/>.  
We have also [some tasks to be done](./docs/todo.md) if you would like to help <img width=16 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f389.svg'/>.

<br/>

I didn't know anything about creation of plugins before having troubles with other rich presence plugins.  
A lot of code from [andweeb/presence.nvim](https://github.com/andweeb/presence.nvim) was used, so I would like to thanks them.
