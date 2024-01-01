if exists('g:loaded_nekovim') | finish | endif
let g:loaded_nekovim = 1

lua << EOF
  require 'nekovim':setup {}

  -- for debugging --
  -- set `idle_time = 2` on the second table argument
EOF
