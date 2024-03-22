<div align='center'>

  # Development <img width=30 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f4bb.svg'>

  [![MIT license](https://img.shields.io/github/license/pandasoli/nekovim?style=for-the-badge&label=License&labelColor=313244&color=ca9ee6)](LICENSE)

  Please read with the code of the last commit of this file.

  [**Pre-requisites**](#pre-requisites-) | [**Setting up environment**](#-setting-up-environment) | [**Taken decisions**](#taken-decisions-)  
  [**Structure**](#-structure) | [**Logs**](#logs-) | [**Generic files**](#-generic-files) | [**Events**](#events-) | [**Core**](#-core)
</div>
<br/>
<br/>

## Pre-requisites <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f392.svg'/>

1. Have already configured the plugin
2. [Type annotations](https://github.com/LuaLS/lua-language-server/wiki/Annotations)
3. Pointers in **Lua** (i.e. tables)

<br/>
<br/>
<br/>
<div align='right'>
  
  ## <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f525.svg'/> Setting up environment
</div>

- Remove the plugin from your plugins list
- Clone the repo

  ```bash
  git clone git@github.com:pandasoli/nekovim.git;\
  cd nekovim
  ```

To test changes run:
```bash
nvim --cmd 'set rtp+=.' <any file path>
```

<br/>
<br/>
<br/>

## Taken decisions <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/2049.svg'/>

To communicate with **Discord** I used the library [discord-ipc](https://github.com/pandasoli/discord-ipc) <img width=20 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f47e.svg'/>.   
It uses a sockets connection (IPC connection - like _vim-sockets_).

<br/>

As **Discord** only accept the instance itself to modify its presence,  
I used [vim-sockets](https://github.com/pandasoli/vim-sockets) <img width=20 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f4fa.svg'/>
to communicate with other instances of **VIM**.  
I maintain one connected instance; others emit [`PresenceProps`](./docs/presence_table.md) when need to update.

<br/>
<br/>
<br/>
<div align='right'>

  ## <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f334.svg'/> Structure
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

<br/>
<br/>
<br/>

## Logging <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f426.svg'/>
> I've modified all deps to log with this

The file `lua/lib/log.lua` contains:
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

<br/>
<br/>
<br/>
<div align='right'>

  ## <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1fae5.svg'/> Generic files
</div>

First, let's see some files you find in any **Lua** <img width=16 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f312.svg'/> program,  
then you will get less lost.

If you need, open them and take a look.

- Everything inside `lua/lib`
- Everything inside `lua/utils`
	- `lua/utils/vim.lua` — **VIM** helpers
- `lua/nekovim/std.lua` — functions to deal with **Lua** data structures

<br/>
<br/>
<br/>

## Events <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f916.svg'/>

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
- `BufWinLeave` — Before closing a buffer

<br/>
<br/>
<br/>
<div align='right'>

  ## <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/26a0.svg'/> Core
</div>

```lua
require 'deps.vim-sockets'

---@class NekoVim
---@field presence_makers PresenceMakers
---@field presence_props  PresenceProps
---@field buffers_props   BuffersProps
---@field work_props      WorkProps
---@field vim_sockets?    VimSockets
---@field current_buf     number
---@field idle_timer?     number
local NekoVim = {}
```

- `presence_props` — store some information about the current status of the presence
- `current_buf` — id of the current buffer
- `idle_timer` — id of **VIM**'s timer used for idling

<br/>
<br/>

Everything starts from `.setup(PresenceMakers, WorkPropsMakers)`.  
It initializes every dependency and property.

It combines the [default](./lua/default_makers/init.lua) and received `PresenceMakers`,  
calls solve the `WorkPropsMakers` to `NekoVim.work_props`,  
sets up multiple instances and the events, if enabled in the `WorkProps`,  
and creates a user command to show logs (`:PrintNekoLogs`).

<br/>
<div align='right'>

  ### <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f991.svg'/> Multiple instances
</div>

If the `WorkProps` received disables multiple instances we just call `:connect()`.  
Otherwise we create two events with _vim-sockets_.
- `update presence` — calls `self:update(Presence?)`
- `make connection` — calls `self:connect()`

And if there are no other instances running we call `:connect()`.

<details>
  <summary>About <code>self.vim_sockets</code></summary>
  <br/>

  &emsp;_vim-sockets_ has functions inside itself used to receive the signals,  
  &emsp;so it needs a way to access itself in other instances.

  &emsp;For that, we added it to `self.vim_sockets`,  
  &emsp;and then passed the path (`package.loaded.nekovim.vim_sockets`).
</details>

<br/>
<div align='right'>

  ### <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f916.svg'/> Events
</div>

If the `WorkProps` received enables events we set up the [`EventHandlers`](./lua/nekovim/event_handlers.lua) and
call `:restart_idle_timer()`. Otherwise we just call `:update(Presence?)`.

`:restart_idle_timer()` sets `presence_props.idling` to false,
then creates a timer that waits some seconds and then sets `presence_props.idling` to true.

<br/>
<div align='right'>

  ### <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f3b2.svg'/> Data makers
</div>

- `:make_buf_props()` creates a `BufferProps` for the current buffer  
	if it doesn't yet exist inside `buffers_props` accessable with the buffer's id

- `:make_presence()` returns a `Presence` based on the `presence_makers`

- `:make_work_props(WorkPropsMakers)` solves `WorkPropsMakers` and returns returns `WorkProps`

<br/>
<br/>
<br/>

### `:update(presence)` <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f3af.svg'/>

```py
if presence:
  if discord.connected:
    # update
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
  &emsp;If not we emit the event `update presence` with the generated `PresenceProps`  
	&emsp;to all other instances, just as [#taken-decisions](#taken-decisions) says.

  &emsp;But if `presence` is valid, the event `update presence` was received.  
  &emsp;If this instance is connected, we update the presence.
</details>

<br/>
<br/>
<br/>
<div align='right'>

  ### <img width=24 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f480.svg'/> `:shutdown()`
</div>

If there is any other instance, we emit the events `make connection` and `update presence`
without pass any value, it will make the instance think `:update` was called by itself and update with its own `PresenceProps`.

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

You probably started reading this doc thinking about helping me in this project <img width=16 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f9f8.svg'/>.  
I cannot give you money <img width=16 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f4b0.svg'/> or anything for your time, but if you still want to help, I would be very happy!

I probably have some [tasks](./docs/todo.md) to be done yet.  
But that's it. This is just one more non-profit project made for devs.

I don't have a server on **Discord** <img width=16 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f47e.svg'/> focused on this project,  
but you can talk to me there if you wish so (see my profile).
