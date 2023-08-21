<div align='center'>

  # Work Props <img width=32 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f477.svg'/>
</div>

**Work Props Makers** works just like [_Presence Makers_](./presence_table.md).  
They generate the _Work Props_. A set of properties that dictate how the plugin works.

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

  <br/>

  <img width=16 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/2757.svg'/> Changing the bot doesn't alter the key for asset access.  
  If an invalid key is used, Discord won't provide a warning or display anything.

  But if you wish, don't worry, all the assets are in [`lua/default_makers/assets/images`](../lua/default_makers/assets/images).

- `multiple`

  It means the plugin handles multiple Vim instances.  
  If you disable, each instance will have its own presence on Discord.

- `events`

  It determines whether the plugin loads Vim events for presence updates.

- `idle_time`

  It specifies the seconds the plugin waits before considering in idle mode.

<br/>
<br/>

<details>
  <summary>See the makers definition</summary>

  ```lua
  ---@class WorkPropsMakers : WorkProps
  ---@field client_id? (fun(): string)|string
  ---@field mutliple?  (fun(): boolean)|boolean
  ---@field events?    (fun(): boolean)|boolean
  ---@field idle_time? (fun(): integer)|integer
  ```
  > <small><code>lua/types/work_props.lua</code></small>
</details>
