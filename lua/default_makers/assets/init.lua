require 'nekovim.std'

---@class Asset
---@field name string
---@field key string
---@field type 'file'|'file explorer'|'plugin manager'

---@alias FilenameMapping {key: string, name: string}

---@class Assets
---@field file_names table<string, FilenameMapping>
---@field file_extensions table<string, FilenameMapping>
---@field file_explorers table<string, string>
---@field file_types table<string, string>
---@field find fun(self: Assets, filePath: string?, fileType: string?): Asset?

---@class Assets
local assets = {
  file_names = {
    ['Cargo.lock'] = { key = 'cargo', name = 'Cargo' },
    ['Cargo.toml'] = { key = 'cargo', name = 'Cargo' },
    ['Gemfile.lock'] = { key = 'ruby', name = 'Gemfile lockfile' },
    Gemfile = { key = 'gemfile', name = 'Gemfile' },
    Procfile = { key = 'heroku', name = 'Heroku config' },
    ['nodemon.json'] = { key = 'nodemon', name = 'Nodemon' },
    ['.prettierrc'] = { key = 'prettier', name = 'Prettier' },
    ['.prettierrc.cjs'] = { key = 'prettier', name = 'Prettier' },
    ['.prettierrc.js'] = { key = 'prettier', name = 'Prettier' },
    ['.prettierrc.json'] = { key = 'prettier', name = 'Prettier' },
    ['.prettierrc.json5'] = { key = 'prettier', name = 'Prettier' },
    ['.prettierrc.toml'] = { key = 'prettier', name = 'Prettier' },
    ['.prettierrc.yaml'] = { key = 'prettier', name = 'Prettier' },
    ['.prettierrc.yml'] = { key = 'prettier', name = 'Prettier' },
    ['prettier.config.cjs'] = { key = 'prettier', name = 'Prettier' },
    ['prettier.config.js'] = { key = 'prettier', name = 'Prettier' },
    ['tailwind.config.js'] = { key = 'tailwind', name = 'Tailwind' },
  },

  file_extensions = {
    ['css.map'] = { key = 'cssmap', name = 'CSS map' },
    ['ts.map'] = { key = 'tsmap', name = 'Typescript map' },
    ['js.map'] = { key = 'jsmap', name = 'JavaScript map' },
    env = { key = 'env', name = 'Env' },
    log = { key = 'log', name = 'Log' },
    cljs = { key = 'clojurescript', name = 'ClojureScript' },
    jar = { key = 'jar', name = 'Java Class' },
    handlebars = { key = 'handlebars', name = 'Handlebars' },
    coffee = { key = 'coffee', name = 'CoffeeScript' },
  },

  file_explorers = {
    TelescopePrompt = 'Telescope',
    nvimtree = 'NvimTree'
  },

  file_types = {
    -- idle = '',
    -- keyboard = '',
    -- lunarvim = '',
    -- objective-c = '',
    make = 'Makefile',
    shell = 'Shell script',
    ps1 = 'Powershell script',
    plaintex = 'Tex',
    wat = 'WebAssembly',
    ahk = 'Autohotkey',
    algol68 = 'ALGOL 68',
    applescript = 'AppleScript',
    assembly = 'Assembly',
    astro = 'Astro',
    bat = 'Batch Script',
    brainfuck = 'Brainfuck',
    c = 'C',
    clojure = 'Clojure',
    cmake = 'CMake',
    cpp = 'C++',
    crystal = 'Crystal',
    csharp = 'C#',
    css = 'CSS',
    d = 'D',
    dart = 'Dart',
    docker = 'Docker',
    editorconfig = 'Editor config',
    elixir = 'Elixir',
    erlang = 'Erlang',
    fish = 'Fish script',
    fortran = 'Fortran',
    fsharp = 'F#',
    gitignore = 'Git ignore',
    gitconfig = 'Git config',
    go = 'Go',
    haskell = 'Haskell',
    hjson = 'HJSON',
    html = 'HTML',
    java = 'Java',
    js = 'JavaScript',
    javascriptreact = 'JavaScript React',
    json = 'JSON',
    kotlin = 'Kotlin',
    less = 'Less',
    lisp = 'Lisp',
    lua = 'Lua',
    markdown = 'Markdown',
    mason = 'Meson',
    moonscript = 'MoonScript',
    nim = 'Nim',
    nix = 'Nix',
    ocaml = 'OCaml',
    pascal = 'Pascal',
    perl = 'Perl',
    php = 'PHP',
    pug = 'Pug',
    purescript = 'PureScript',
    python = 'Python',
    r = 'R',
    racket = 'Racket',
    raku = 'Raku',
    ruby = 'Ruby',
    rust = 'Rust',
    sass = 'Sass',
    scala = 'Scala',
    sql = 'SQL',
    stylus = 'Stylus',
    svelte = 'Svelte',
    svg = 'Svg',
    swift = 'Swift',
    text = 'Text',
    toml = 'TOML',
    ts = 'Typescript',
    typescriptreact = 'Typescript React',
    v = 'V',
    vb = 'Visual Basic',
    vim = 'Vim',
    vue = 'Vue',
    xml = 'XML',
    yaml = 'YAML',
    zig = 'Zig'
  }
}

---@param filePath string?
---@param fileType string?
---@return Asset?
function assets:find(filePath, fileType)
  local res

  if filePath ~= nil then
    local fileName = filePath and filePath:match '[^/\\]+$' or nil
    res = self.file_names[fileName]
    if res then
      return { type = 'file', key = res.key:lower(), name = res.name }
    end

    local fileExt = fileName and fileName:match '%.(.+)$' or nil
    res = self.file_extensions[fileExt]
    if res then
      return { type = 'file', key = res.key:lower(), name = res.name }
    end
  end

  if fileType ~= nil then
    res = self.file_types[fileType]
    if res then
      return { type = 'file', key = fileType:lower(), name = res }
    end

    res = self.file_explorers[fileType]
    if res then
      return { type = 'file explorer', key = fileType:lower(), name = res }
    end
  end
end

return assets
