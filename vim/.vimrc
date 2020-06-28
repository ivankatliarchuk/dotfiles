"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Lines of history to remember
set history=500

" Highlight search results
set hlsearch

" Helps force plugins to load correctly when it is turned back on below
filetype off

" Set line number
set number
" Filetype detection, plugins, and indent rules
filetype plugin indent on

" Readability
syntax on
colo pablo

" Use spaces instead of tabs
set expandtab
set softtabstop=4

set autoindent "Use indent from current line for next line
set autoread "Detect when file changes outside of Vim
set smartindent "Be clever when code cues are recognized
set wrap "Wrap lines

" Spell check and line wrap for git commit messages
autocmd Filetype gitcommit setlocal spell textwidth=72

" Show line numbers
set number

" Show file stats
set ruler

" Encoding
set encoding=utf-8

" Whitespace
set wrap
set textwidth=79
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set noshiftround

" Last line
set showmode
set showcmd

" Visualize tabs and newlines
set listchars=tab:▸\ ,eol:¬
" Uncomment this to enable by default:
" set list " To enable by default
" Or use your leader key + l to toggle on/off
map <leader>l :set list!<CR> " Toggle tabs and EOL

" Color scheme (terminal)
set t_Co=256
set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1
" put https://raw.github.com/altercation/vim-colors-solarized/master/colors/solarized.vim
" in ~/.vim/colors/ and uncomment:
" colorscheme solarized
