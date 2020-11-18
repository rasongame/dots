source ~/.config/nvim/config.vim

call plug#begin(stdpath('data') . '/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jacoborus/tender.vim'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'sbdchd/neoformat'
Plug 'jiangmiao/auto-pairs'
Plug 'racer-rust/vim-racer'
"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vim-scripts/gruvbox'
call plug#end()

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

colorscheme gruvbox
set background=dark
let g:airline#extensions#tabline#enabled = 1
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
