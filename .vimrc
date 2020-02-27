" let mapleader = ','
" set showcmd

" ca=command aliase, so typing :W is the same as typing :w
ca W w

syntax on
"Wraps around lines when using arrow keys:
"set whichwrap+=<,>,h,l,[,]
set number

func! WordProcessorMode() 
  setlocal formatoptions=1 
  setlocal noexpandtab 
  map j gj 
  map k gk
  setlocal spell spelllang=en_us 
  set thesaurus+=/Users/rand/Priv/vim/mthesaur.txt
  set complete+=s
  set formatprg=par
  setlocal wrap 
  setlocal linebreak
  "set textwidth=40
endfu 
com! WP call WordProcessorMode()

" press esc two times to save the file
" don't use this, because when ESC+arrows inserts A, B, C, D
"imap <Esc><Esc> :w<CR>

" If you search for something containing uppercase characters, it will do a case sensitive search; if you search for something purely lowercase
set smartcase

" prevent vim from re-tabbing your code
set nopaste

highlight Comment ctermbg=Grey ctermfg=White
highlight Constant ctermbg=Yellow

syntax enable
hi Constant cterm=none
hi Special cterm=none
hi Identifier cterm=none

set clipboard=unnamedplus
" highlight the current line
" set cursorline

set numberwidth=5  "Good for files upto a million lines
set columns=85
set nu
set linebreak
"colorscheme morning
