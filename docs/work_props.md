<div align='center'>

  # Work Props <img width=32 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f477.svg'/>
</div>

**`WorkPropsMakers`** works just like [`PresenceMakers`](./presence_table.md).  
They generate the `WorkProps`, a set of properties that dictate how the plugin behaves.

```lua
---@class WorkProps
---@field client_id? string
---@field multiple?  boolean
---@field events?    boolean
---@field idle_time? integer
```

<br/>
<br/>

- `client_id`

  It is the Discord bot's application id.

  > <img width=16 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/2757.svg'/> Changing the bot doesn't alter the key for asset access.  
  > If an invalid key is used, Discord won't provide a warning or display anything.
	> 
  > But if you wish to change it, don't worry, all the assets are in [`lua/default_makers/assets/images`](../lua/default_makers/assets/images).

- `multiple`

  It means whether the plugin handles multiple **Vim** instances.  
  If you disable it, each instance will have its own presence on Discord.

- `events`

  It determines whether the plugin loads **Vim** events for presence updates.

- `idle_time`

  It specifies the seconds the plugin waits before considering in idle mode.  
	It doesn't work when `events` is disabled.

<br/>
<br/>

<details>
  <summary>See makers definition</summary>

  ```lua
  ---@class WorkPropsMakers : WorkProps
  ---@field client_id? (fun(): string)|string
  ---@field mutliple?  (fun(): boolean)|boolean
  ---@field events?    (fun(): boolean)|boolean
  ---@field idle_time? (fun(): integer)|integer
  ```
  > <small><code>lua/types/work_props.lua</code></small>
</details>
