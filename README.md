<img height=150 align='right' src='./docs/undraw_welcome_cats_thqn.svg'/>

# Neko[Vim](https://vim.org) &nbsp; <img width=32 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f408.svg'/> <img width=32 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f311.svg'/><img width=32 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2728.svg'/>

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
- Multiple instances
- Really highly configurable

  > The only thing you cannot change is the title “NekoVim” (Discord bot name).  
  > But you can change the used bot.

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
---@type PresenceMakers
require 'Nekovim':setup {}
```

More info about **Presence Makers** in [Presence Table](./docs/presence_table.md).

<br/>
<br/>
<div align='right'>

  ## <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f9d1-200d-1f4bb.svg'/> Development
</div>

A doc of developers will be released soon.

<br/>
<!-- Before creating a pull request, read the [docs for developers](./DEVELOPMENT.md) <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2615.svg'/>. -->

I didn't know anything about creation of plugins before having troubles with other rich presence plugins.  
A lot of code from [andweeb/presence.nvim](https://github.com/andweeb/presence.nvim) was used, so I would like to thanks them.