require 'nekovim.std'

---@class AssetSource
---@field name string
---@field key string

---@class Asset : AssetSource
---@field type 'languages'|'file_explorers'|'plugin_managers'

---@class Assets
local assets = {
  languages = {
    Dockerfile = { name = 'Docker', key = 'docker' },

    gitignore = { name = 'Git ignore', key = 'git' },
    markdown = { name = 'Markdown', key = 'markdown' },
    README = { name = 'README file', key = 'markdown' },
    LICENSE = { name = 'LICENSE', key = 'text' },

    make = { name = 'Makefile', key = 'makefile' },
    cmake = { name = 'CMake', key = 'cmake' },

    c = { name = 'C', key = 'c' },
    h = { name = 'C header', key = 'c' },

    algol68 = { name = 'ALGOL 68', key = 'algol68' },

    cpp = { name = 'C++', key = 'cpp' },
    hpp = { name = 'C++ header', key = 'cpp' },

    cs = { name = 'C#', key = 'csharp' },
    csx = { name = 'C#', key = 'csharp' },

    m = { name = 'Objective-C', key = 'objective-c' },
    swift = { name = 'Swift', key = 'swift' },

    ['Gemfile.lock'] = { name = 'Gemfile lockfile', key = 'ruby' },
    Gemfile = { name = 'Gemfile', key = 'gemfile' },
    gemspec = { name = 'Gem Spec', key = 'ruby' },
    ruby = { name = 'Ruby', key = 'ruby' },

    fs = { name = 'F#', key = 'fsharp' },

    f = { name = 'Fortran', key = 'fortran' },
    f90 = { name = 'Fortran 90', key = 'fortran' },
    f95 = { name = 'Fortran 95', key = 'fortran' },

    d = { name = 'D', key = 'd' },

    sql = { name = 'SQL', key = 'sql' },

    gomod = { name = 'go.mod', key = 'go' },
    gosum = { name = 'go.sum', key = 'go' },
    go = { name = 'Go', key = 'go' },

    asm = { name = 'Assembly', key = 'assembly' },
    a = { name = 'Assembly', key = 'assembly' },

    ['.bashrc'] = { name = 'Shell script', key = 'shell' },
    sh = { name = 'Shell script', key = 'shell' },
    cmd = { name = 'Batch script', key = 'bat' },
    bat = { name = 'Batch script', key = 'bat' },
    fish = { name = 'Fish script', key = 'fish' },
    ps1 = { name = 'PowerShell', key = 'powershell' },
    psd1 = { name = 'PowerShell', key = 'powershell' },
    psm1 = { name = 'PowerShell', key = 'powershell' },
    applescript = { name = 'AppleScript', key = 'applescript' },
    vim = { name = 'Vim script', key = 'vim' },

    lua = { name = 'Lua', key = 'lua' },
    moonscript = { name = 'MoonScript', key = 'moonscript' },

    purescript = { name = 'PureScript', key = 'purescript' },
    purs = { name = 'PureScript', key = 'purescript' },

    php = { name = 'PHP', key = 'php' },

    bf = { name = 'Brainfuck', key = 'brainfuck' },

    hjson = { name = 'HJSON', key = 'hjson' },
    json = { name = 'JSON', key = 'json' },
    xml = { name = 'XML', key = 'xml' },
    yaml = { name = 'YAML', key = 'yaml' },
    ini = { name = 'Configuration file', key = 'env' },
    env = { name = 'Environment', key = 'env' },
    log = { name = 'Log', key = 'log' },

    ['Cargo.lock'] = { name = 'Cargo lockfile', key = 'cargo' },
    ['Cargo.toml'] = { name = 'Cargo.toml', key = 'cargo' },
    toml = { name = 'TOML', key = 'toml' },
    rs = { name = 'Rust', key = 'rust' },
    wasm =  { 'WebAssembly', key = 'wasm' },

    ['v.mod'] = { name = 'v.mod', key = 'v' },
    v = { name = 'Vlang', key = 'v' },
    vsh = { name = 'Vlang shell script', key = 'v' },

    nim = { name = 'Nim', key = 'nim' },

    nix = { name = 'Nix', key = 'nix' },

    ahk = { name = 'Autohotkey', key = 'ahk' },

    crystal = { name = 'Crystal', key = 'crystal' },

    elixir = { name = 'Elixir', key = 'elixir' },

    erlanv = { name = 'Erlang', key = 'erlang' },

    zig = { name = 'Zig', key = 'zig' },

    dart = { name = 'Dart', key = 'dart' },

    vb = { name = 'Visual Basic', key = 'vb' },

    perl = { name = 'Perl', key = 'perl' },

    svg = { name = 'SVG', key = 'svg' },
    txt = { name = 'Text', key = 'text' },

    ['tailwind.config.js'] = { name = 'Tailwind', key = 'tailwind' },
    html = { name = 'HTML', key = 'html' },
    handlebars = { name = 'Handlebars', key = 'handlebars' },
    pug = { name = 'Pug', key = 'pug' },
    ['css.map'] = { name = 'CSS map', key = 'cssmap' },
    css = { name = 'CSS', key = 'css' },
    sass = { name = 'Sass', key = 'sass' },
    scss = { name = 'Scss', key = 'sass' },
    less = { name = 'Less', key = 'less' },
    styl = { name = 'Stylus', key = 'stylus' },
    stylus = { name = 'Stylus', key = 'stylus' },

    ['.prettierrc'] = { name = 'Prettier', key = 'prettier' },
    ['.prettierrc.cjs'] = { name = 'Prettier', key = 'prettier' },
    ['.prettierrc.js'] = { name = 'Prettier', key = 'prettier' },
    ['.prettierrc.json'] = { name = 'Prettier', key = 'prettier' },
    ['.prettierrc.json5'] = { name = 'Prettier', key = 'prettier' },
    ['.prettierrc.toml'] = { name = 'Prettier', key = 'prettier' },
    ['.prettierrc.yaml'] = { name = 'Prettier', key = 'prettier' },
    ['.prettierrc.yml'] = { name = 'Prettier', key = 'prettier' },
    ['prettier.config.cjs'] = { name = 'Prettier', key = 'prettier' },
    ['prettier.config.js'] = { name = 'Prettier', key = 'prettier' },

    ['nodemon.json'] = { name = 'Nodemon', key = 'nodemon' },
    Procfile = { name = 'Heroku config', key = 'heroku' },
    javascript = { name = 'JavaScript', key = 'js' },
    javascriptreact = { name = 'React', key = 'jsx' },
    ['js.map'] = { name = 'JavaScript map', key = 'jsmap' },
    typescript = { name = 'TypeScript', key = 'ts' },
    typescriptreact = { name = 'React', key = 'tsx' },
    ['ts.map'] = { name = 'TypeScript map', key = 'tsmap' },
    coffee = { name = 'CoffeeScript', key = 'coffee' },
    svelte = { name = 'Svelte', key = 'svelte' },
    vue = { name = 'Vue', key = 'vue' },
    astro = { name = 'Astro', key = 'astro' },

    python = { name = 'Python', key = 'python' },
    r = { name = 'R', key = 'r' },

    tex = { name = 'LaTeX', key = 'tex' },

    pascal = { name = 'Pascal', key = 'pascal' },

    java = { name = 'Java', key = 'java' },
    jar = { name = 'Java Class', key = 'jar' },
    kotlin = { name = 'Kotlin', key = 'kotlin' },
    scala = { name = 'Scala', key = 'scala' },

    raku = { name = 'Raku', key = 'raku' },

    lisp = { name = 'Common Lisp', key = 'lisp' },
    racket = { name = 'Racket', key = 'racket' },
    clj = { name = 'Clojure', key = 'clojure' },
    cljs = { name = 'ClojureScript', key = 'clojurescript' },

    hs = { name = 'Haskell', key = 'haskell' },
    lhs = { name = 'Haskell', key = 'haskell' },

    ocaml = { name = 'OCaml', key = 'ocaml' }
  },

  file_explorers = {
    NvimTree = { name = 'NvimTree', key = 'nvimtree' },
    TelescopePrompt = { name = 'Telescope', key = 'telescope' }
  },

  plugin_managers = {
    ['vim-plug'] = { name = 'VimPlug', key = 'vim-plug' },
    packer = { name = 'Packer', key = 'packer' },
    mason = { name = 'Mason', key = 'mason' }
  }
}

---@param filePath string?
---@param fileType string?
---@return Asset
function assets:test(filePath, fileType)
  local txt_res = JoinTables({ type = 'language' }, self.languages['txt'])

  if not fileType then
    return txt_res
  end

  local fileName = filePath and filePath:match '[^/\\]+$' or nil
  local fileExtension = fileName and fileName:match '%.(.+)$' or nil
  local res

  local function test_lang()
    -- Try with file's name
    if fileName then
      res = self.languages[fileName]
      if res then return end
    end

    -- Try with filetype
    res = self.languages[fileType]
    if res then return end

    -- Try with file's extension
    if fileExtension then
      res = self.languages[fileExtension]
    end
  end

  local function test_file_explorer()
    -- Try with filetype
    res = self.file_explorers[fileType]
  end

  local function test_plugin_manager()
    -- Try with filetype
    res = self.plugin_managers[fileType]
  end

  test_lang()
  if res then return JoinTables({ type = 'language' }, res) end

  test_file_explorer()
  if res then return JoinTables({ type = 'file explorer' }, res) end

  test_plugin_manager()
  if res then return JoinTables({ type = 'plugin manager' }, res) end

  return txt_res
end

return assets
