if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
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

call plug#end()
" ---== Deoplete ==---
let g:deoplete#enable_at_startup = 1
call deoplete#enable()

syntax on
" ---== Configuration ==---
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
colorscheme arstotzka

" ---== Mappings ==---

map <C-q> :q!<CR>
map <C-w> :w!<CR>
map <C-n> :NERDTreeToggle<CR>
