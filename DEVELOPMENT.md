<div align='center'>

  # <img width=32 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f9d1-200d-1f4bb.svg'/> Development
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  ![GitHub Repo stars](https://img.shields.io/github/stars/pandasoli/nekovim)

  Please read with the code of the last commit of this file.

  <br/>

  [**Pre-requisites**](#pre-requisites-) | [**Setting up environment**](#-setting-up-environment) |
  [**Taken decisions**](#taken-decisions-) | [**Logs**](#-logs) |
  [**Structure**](#structure-)  
  Understanding the code: [**Generic files**](#-generic-files) | [**Core**](#core-)

  [**TO DO**](docs/todo.md)
</div>
<br/>
<br/>

## Pre-requisites <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f914.svg'/>

1. <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f517.svg'/> [Lua type annotations](https://github.com/LuaLS/lua-language-server/wiki/Annotations)
2. Have already configured the plugin
3. Pointers in Lua (i.e. tables)

<br/>
<br/>
<br/>
<div align='right'>

  ## <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f4bb.svg'/> Setting up environment
</div>

- Remove the plugin from your plugins list
- Clone it

  ```bash
  git clone https://github.com/pandasoli/nekovim; \
  cd nekovim
  ```
- To test the modifications run the file `run`
  > `nvim --cmd 'set rtp+=./' <file path to open>`

<br/>
<div align='right'>

  Step done, hit the coffee <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2615.svg'/>
</div>

<br/>
<br/>
<br/>

## Taken decisions <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2049.svg'/>

To communicate with **Discord** I used the library [discord-ipc](https://github.com/pandasoli/discord-ipc) <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f47e.svg'/>.  
It uses a sockets connection (IPC connection - like _vim-sockets_).

<br/>

As **Discord** only accept the instance itself to modify its presence, I used [vim-sockets](https://github.com/pandasoli/vim-sockets) <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f4fa.svg'/>
to communicate with other instances of **Vim**.

When an instance that is not connected to **Discord** needs to update,
it sends a signal containing the presence table to all the other instances.

<br/>
<br/>
<br/>
<div align='right'>

  ## <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f426.svg'/> Logs
</div>

The file `lua/lib/log.lua` contains:
```lua
---@class Logger
---@field logs          string[]
---@field log           fun(self: Logger, from: string, ...: any)
---@field tostring      fun(self: Logger): string                 Join all logs
---@field print         fun(self: Logger)
---@field write_to_file fun(self: Logger)                         Write logs to ./nekovim.log
```

I've modified all deps to receive this class.

<br/>
<br/>
<br/>

## Structure <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f332.svg'/>

- **lua**
  - **default_makers**
    - **assets**
      - **images** — all default available icons
        > this is not used,  
        > I just leave it here in case you want to download it.

  - **deps** — dependencies/used libraries
  - **lib** — some generic scripts
  - **nekovim** — source folder
  - **types** — type definitions
  - **utils** — useful scripts
- **plugin** — Vim plugin files
  - **nekovim.vim** — File that runs after the editor’s config

<br/>
<br/>
<br/>
<div align='right'>

  ## <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2702.svg'/> Generic files
</div>

First, I’ll show you the type of file you find in any **Lua** <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f312.svg'/> program, then you will not get lost.

I’ll list them and you take a look.

- All files in `lua/lib`
- All files in `lua/utils`
- `lua/nekovim/std.lua` — functions to help deal with **Lua** data
- `lua/nekovim/vim_utils.lua` — Vim helpers

<br/>
<br/>
<br/>

## Core <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/26a0.svg'/>

First, read about the [Presence Table](./docs/presence_table.md).

```lua
require 'deps.vim-sockets'

---@class NekoVim
---@field presence_makers PresenceMakers
---@field presence_props  PresenceProps
---@field buffer_props    BufferProps
---@field vim_sockets     VimSockets
---@field logger          Logger
local NekoVim = {}
```

<br/>
<br/>

Everything starts with `:setup(makers)`:
- Combines default and received presence makers
- Starts _vim-sockets_
  <br/><br/>
  It creates two events in _vim-sockets_:
  - `update presence` called by non-connected instances
  - `make connection` called when the connected instance exits
  <br/><br/>
- Start the _Presence Props_
- Setup the _Event Handlers_
- Creates a connection with **Discord** if there is no other instances/sockets
- Creates a command to print the logs
  <br/><br/>
  <img width=14 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2139.svg'/> _Logger_ has a function to print.  
  To make it accessable we added it to `self.logger`.
  <br/><br/>
- Initializes the loaded variable
  <br/><br/>
  This prevents the plugin from being loaded twice by `plugin/nekovim.vim`.

<br/>
<br/>

Data maker functions:
- `:make_buf_props()` makes `self.presence_props`
- `:make_presence()` makes a new presence table

<br/>
<br/>

The `:update(presence)` function is called also for update of other instances.  
The `:shutdown()` function is called

<!-- It does the following: -->
<!-- - Joins default and received presence maker -->
<!--   > Allowing key replacement while retaining the rest. -->

<!-- - Initializes used deps -->

<!--   We initialize **VimSockets** in **NekoVim**, -->
<!--   ‘cause it needs to locate an instance of itself in other instances to find the update function, -->
<!--   so we passed it as `'package.loaded.nekovim.vimSockets'`. -->

<!-- - Enables `g:loaded_nekovim` variable to prevent reloading in `plugin/nekovim.vim` -->

<!-- - Create the command `:PrintLogs` to print all the created logs. -->

<!--   This is the reason why we have the field `self.logger` - Access the logs through `package.loaded.nekovim`. -->

<!-- <br/> -->
<!-- <br/> -->

<!-- - `:make_presence()` — created and returns the [presence table](./docs/presence_table.md) -->
<!-- - `:make_props()` — updates `Nekovim.props` -->

<!-- <br/> -->

<!-- - `:update(presence)` — updates Discord presence -->
<!--   <br/><br/> -->
<!--   > It receives a presence table in case of it's being called from another instance.   -->
<!--   > If it's not received we call `:make_presence()`, send it to all instances, and updates. -->
<!-- - `:shutdown()` — finishes all connections -->
