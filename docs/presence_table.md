<div align='center'>

  # Presence table <img width=32 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f4cb.svg'/>
</div>

The presence table that **Discord** expects:

<img align='right' height=420 src='./discord_presence_preview.png'/>

```lua
---@class PresenceButton
---@field label string
---@field url   string

---@class PresenceAssets
---@field large_image? string
---@field large_text?  string
---@field small_image? string
---@field small_text?  string

---@class PresenceTimestamps
---@field start? integer
---@field end?   integer

---@class Presence
---@field state?      string
---@field details?    string
---@field timestamps? PresenceTimestamps
---@field assets?     PresenceAssets
---@field buttons?    PresenceButton[]
```
> <small><code>lua/deps/discord/types/activity.lua</code></small>

<br/>
<div align='center'>

  # Presence Makers <img width=32 src='https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f477.svg'/>
</div>

We use `PresenceMakers` to generate the _Presence Table_.

They are structured as the _Presence Table_.  
Their fields can be a function that returns the expected value or it directly.

<details>
  <summary>See declaration</summary>

  ```lua
  ---@class PresenceMakersAssets : PresenceAssets
  ---@field large_image? (fun(self: NekoVim): string)|string
  ---@field large_text?  (fun(self: NekoVim): string)|string
  ---@field small_image? (fun(self: NekoVim): string)|string
  ---@field small_text?  (fun(self: NekoVim): string)|string

  ---@class PresenceMakersTimestamps : PresenceTimestamps
  ---@field start? (fun(self: NekoVim): integer)|integer
  ---@field end?   (fun(self: NekoVim): integer)|integer

  ---@class PresenceMakers : Presence
  ---@field state?     (fun(self: NekoVim): string)|string
  ---@field details?   (fun(self: NekoVim): string)|string
  ---@field timestamps PresenceMakersTimestamps
  ---@field assets?    PresenceMakersAssets
  ---@field buttons?   ((fun(self: NekoVim): PresenceButton)|PresenceButton)[]
  ```
  > <small><code>lua/types/presence_makers.lua</code></small>
</details>

<br/>
<br/>

The functions receive an instance of **NekoVim** because of:  

<details>
  <summary><code>NekoVim.buffers_props</code></summary>

  Every time a new buffer is open we register its properties (`BufferProps`)  
  in a table organizaed by ids (`BuffersProps`).

  ```lua
  ---@class BufferPropsRepo
  ---@field owner string
  ---@field name  string

  ---@class BufferProps
  ---@field mode          'n'|'i'|'v'|'c'|'R'|string
  ---@field repo          BufferPropsRepo
  ---@field fileName      string?
  ---@field filePath      string?
  ---@field fileType      string?
  ---@field fileExtension string?

  ---@class BuffersProps
  ---@field [number] BufferProps
  ```
  > <small><code>lua/types/buffers_props.lua</code></small>

</details>
<details>
  <summary><code>NekoVim.presence_props</code></summary>

  ```lua
  ---@class PresenceProps
  ---@field startTimestamp integer
  ---@field idling         boolean
  ```
  > <small><code>lua/types/presence_props.lua</code></small>

  <br/>

  See more about `idling` in [`WorkProps`](./work_props.md).
</details>
