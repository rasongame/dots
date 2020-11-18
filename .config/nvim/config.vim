set hidden
set cmdheight=2
set updatetime=300
set shortmess+=c
set termguicolors
set mouse=a
set hidden
set number
set nobackup       
set nowritebackup  
set noswapfile
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set showcmd
map <F2> :w! <CR>
map <F3> :NERDTreeToggle <CR>
map <F4> :CocFix <CR>
nnoremap <c-p> :Files <CR>
map <F5> :make <CR>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

syntax enable
filetype plugin indent on
command! -nargs=0 Format :call CocAction('format')

autocmd vimenter * NERDTree
let g:fzf_action = {
    \ 'ctrl-t': 'tab split', 
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit' }
let g:fzf_preview_window = "right:80%"
augroup fzf
    autocmd!
	autocmd! FileType fzf
	autocmd FileType fzf set laststatus=0 noshowmode noruler 
                \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup END
augroup Formatting
	autocmd!
	autocmd BufWritePre * undojoin | :Format
augroup END

