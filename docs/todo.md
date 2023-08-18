<div align='center'>

  # To Do <img width=32 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f4cb.svg'/>

  When completed, tasks appear checked with the dev's name <img width=20 src='https://raw.githubusercontent.com/pandasoli/twemojis/master/1f4bb.svg'/>
</div>
<br/>
<br/>

- [ ] Get `repoName` with **Git** in `Nekovim:make_buf_props`
- [ ] Try implementing AFK status
- [ ] Add option to disable Vim events
- [ ] Add option to disable multiple instances
- [ ] Maybe: Double connection  
  If you edit the plugin's config while it's running,  
  and ther's no other instances runnings,  
  it will try to connect to **Discord** again.

  So a check `Discord.tried_connection` is needed.

  ```lua
  if #VimSockets.sockets == 0 then
    self:connect()
  end
  ```

<br/>
<br/>

### Core
