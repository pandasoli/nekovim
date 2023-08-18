<div align='center'>

  # Development <img width=30 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f4bb.svg'>

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

  Please read with the code of the last commit of this file.

  [**Pre-requisites**](#pre-requisites-) | [**Setting up environment**](#-setting-up-environment) | [**Taken decisions**](#taken-decisions-)  
  [**Structure**](#-structure) | [**Logs**](#logs-) | [**Generic files**](#-generic-files) | [**Events**](#events-) | [**Core**](#-core)
</div>
<br/>
<br/>

## Pre-requisites <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f392.svg'/>

1. [Type annotations](https://github.com/LuaLS/lua-language-server/wiki/Annotations)
2. Have already configured the plugin
3. Pointers in **Lua** (i.e. tables)

<br/>
<br/>
<br/>
<div align='right'>
  
  ## <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f525.svg'/> Setting up environment
</div>

- Remove the plugin from your plugins list
- Clone the repo

  ```bash
  git clone https://github.com/pandasoli/nekovim;\
  cd nekovim
  ```

<br/>

To test changes run:
  ```bash
  nvim --cmd 'set rtp+=.' <any file path>
  ```

<br/>
<br/>
<br/>

## Taken decisions <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2049.svg'/>

To communicate with **Discord** I used the library [discord-ipc](https://github.com/pandasoli/discord-ipc) <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f47e.svg'/>.   
It uses a sockets connection (IPC connection - like _vim-sockets_).

<br/>

As **Discord** only accept the instance itself to modify its presence,  
I used [vim-sockets](https://github.com/pandasoli/vim-sockets) <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f4fa.svg'/>
to communicate with other instances of **Vim**.

I maintain one connected instance; others emit the [_Presence Table_](./docs/presence_table.md) when need to update.

<br/>
<br/>
<br/>
<div align='right'>

  ## Structure <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f334.svg'/>
</div>

- **lua**
  - **default_makers**
    - **assets**
      - **images** — all default available icons
        > This is not used,  
        > I just leave it here in case you want to download it.

  - **deps** — dependencies/used libraries
  - **lib** — some generic scripts
  - **nekovim** — source folder
  - **types** — type definitions
  - **utils** — useful scripts
- **plugin** — **Vim** plugin files
  - **nekovim.vim** — File that runs after the editor’s config

<br/>
<br/>
<br/>

## Logs <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f426.svg'/>

The package `lua/lib/log.lua` contains:
```lua
---@class Logger
---@field logs          string[]
--
---@field debug         fun(self: Logger, from: string, ...: any)
---@field info          fun(self: Logger, from: string, ...: any)
---@field warn          fun(self: Logger, from: string, ...: any)
---@field error         fun(self: Logger, from: string, ...: any)
--
---@field print         fun(self: Logger)
---@field write_to_file fun(self: Logger)
local Logger = {}
```

I've modified all deps to log with it.

<br/>
<br/>
<br/>
<div align='right'>

  ## <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1fae5.svg'/> Generic files
</div>

First, let's see some files file you find in any Lua <img width=16 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f312.svg'/> program,  
then you will get less lost.

If you need, take a look at them.

- Everything inside `lua/lib`
- Everything inside `lua/utils`
- `lua/nekovim/std.lua` — functions to help deal with data
- `lua/nekovim/vim_utils.lua` — **Vim** helpers

<br/>
<br/>
<br/>

## Events <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f916.svg'/>

`lua/nekovim/event_handlers.lua` handles all the events.

```lua
---@param nekovim NekoVim
---@param log_to_file? boolean # Write logs to file every time an event is trigged
function EventHandlers:setup(nekovim, log_to_file) end
```

<br/>

- `VimLeavePre` — Before exiting **Vim**
- `FocusGained` — When focus the window
- `BufEnter` — When select another buffer
- `ModeChanged` — When change the mode (normal, visual, replace...)

<br/>
<br/>
<br/>
<div align='right'>

  ## Core <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/26a0.svg'/>
</div>

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

Everything start from `:setup(makers: PresenceMakers)`.  
It initializes every dependency and property.

<details>
  <summary>About <code>self.vim_sockets</code></summary>
  <br/>

  &emsp;_vim-sockets_ has functions inside itself used to receive the signals,  
  &emsp;so it needs a way to access itself in other instances.

  &emsp;For that, we added it to `self.vim_sockets`,  
  &emsp;and then passed the path (`package.loaded.nekovim.vim_sockets`).
</details>

<details>
  <summary>About <code>self.logger</code></summary>

  &emsp;The only way to run a function with `command!` is calling it through `package.loaded`.

  &emsp;So it was needed to create `:PrintNekoLogs`, now we use `package.loaded.nekovim.logger:print()`.
</details>

<br/>
<br/>

Data makers <img width=16 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f3b2.svg'/>
- `:make_presence()` returns a _Presence Table_ created with `self.presence_makers`
- `:make_buf_props()` generates `self.buffer_props`

<br/>
<div align='right'>

  ### <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f991.svg'/> Multiple instances
</div>

If there are no other instances, `:setup` calls `:connect()`.  
_discord-ipc_ has a field `tried_connection` so we consider connected even if unconnected.

<br/>

We create two events with _vim-sockets_.
- `update presence` — calls `self:update(presence: Presence?)`
- `make connection` — calls `self:connect()`

<br/>

### `:update(presence)` <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f3af.svg'/>

<br/>

```py
if presence:
  if discord.connected: # update
else:
  if presence := self.make_presence():
    if discord.connected:
      # update
    else:
      self.vim_sockets.emmit('update presence', presence)
```
> <small>Illustration</small>

<details>
  <summary>Text explanation</summary>

  &emsp;If the current instance is connected we just update.  
  &emsp;If not we emit the event `update presence` with the generated _Presence Table_ to all other instances.

  &emsp;But if `presence` is valid, the event `update presence` was received.  
  &emsp;If this instance is connected, we update the presence.
</details>

<br/>

### `:shutdown()` <img width=24 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f480.svg'/>

<br/>

If there is any other instance, we emit the events `make connection`,
and `update presence` without pass any value,
it will make the instance think `:update` was called by it itself and update with its own _Presence Table_.

<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<div align='center'>

  # Journey Ended
</div>
<br/>

You probably started reading this doc thinking about helping me in this project <img width=16 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f9f8.svg'/>.  
I cannot give you money <img width=16 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f4b0.svg'/> or anything for your time, but if you still want to help, I would be very happy!

I probably have some [tasks](./docs/todo.md) to be done yet.  
But that's it. This is just one more non-profit project made for devs.

I don't have a server on **Discord** <img width=16 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f47e.svg'/> focused on this project,  
but you can talk to me there if you wish so (see my profile).
