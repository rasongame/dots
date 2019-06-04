if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source ~/.vimrc
endif

call plug#begin('~/.vim/plugged')

" ---== Plugin list ==---
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'bling/vim-airline'
Plug 'jiangmiao/auto-pairs'
Plug 'airblade/vim-gitgutter'
Plug 'morhetz/gruvbox'
Plug 'rainglow/vim'
Plug 'othree/html5.vim'
Plug 'mattn/emmet-vim'
Plug 'arcticicestudio/nord-vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'ryanolsonx/vim-lsp-python'
Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
Plug 'deoplete-plugins/deoplete-jedi' 
call plug#end()
" ---== Deoplete ==---

let g:deoplete#enable_at_startup = 1
call deoplete#enable()

syntax on
" ---== Emmet ==--- 

let g:user_emmet_leader_key='<C-z>'

"  ---== Configuration ==---
set wrap
set ai
set tabstop=4
set shiftwidth=4
set smarttab
set hlsearch
set incsearch
set number
set listchars=tab:··
set list

" ---== Color scheme ==---
colorscheme nord
" ----== AirLine ==----
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.whitespace = 'Ξ'

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
" ---= VIM Language Support Servers..  ==---
if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif


"
"
" ---== Mappings ==---

map <C-q> :q!<CR>
map <C-w> :w!<CR>
map <C-n> :NERDTreeToggle<CR>
map <C-t> :tabNext<CR>
