if exists('g:loaded_nekovim') | finish | endif
let g:loaded_nekovim = 1

lua << EOF
require 'nekovim':setup({
multiple = false
})
EOF
