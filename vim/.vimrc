" automatically downloads vim-plug to your machine if not found.
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Define plugins to install
call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'bfrg/vim-cpp-modern'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" General Remap
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

nnoremap <space> <Nop>
let mapleader = " "
map <leader>q :bp<bar>sp<bar>bn<bar>bd<CR> 
map <leader>qq %bd<bar>e#<bar>bd#<CR>
nnoremap ; :
vnoremap ; :
noremap <space>r <C-^>

" Remaps for fzf
nnoremap <silent> <leader>f :GFiles<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>h :History<CR>
nnoremap <silent> <leader>h: :History:<CR>
nnoremap <silent> <leader>h/ :History/<CR>
nnoremap <silent> <leader>h: :History:<CR>
nnoremap <silent> <leader>se :Rg<CR>

" Remap for COC
nnoremap <silent> <leader>y :<C-u>CocList -A --normal yank<CR>
nnoremap <leader>cyc :CocCommand yank.clean<CR>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> ree :<C-u>CocList diagnostics<CR>
nmap <silent> do <Plug>(coc-codeaction)
nmap <silent> rnm <Plug>(coc-rename)
nmap <silent> gs :call CocActionAsync('showSignatureHelp')<CR>

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"



" Setup Options

let g:fzf_preview_window = ''

if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

colorscheme desert
hi Normal ctermbg=None
hi EndOfBuffer ctermbg=None

set completeopt-=preview
set scrolloff=8
set number
set relativenumber
set tabstop=4 
set softtabstop=4
set shiftwidth=4
set shiftround
set noexpandtab
set smartindent
set nocompatible
set backspace=2
set nobackup
set nowritebackup
set noswapfile
set showcmd
set laststatus=2
set modelines=0
set nomodeline
set nojoinspaces
set hlsearch
set wildmenu
set incsearch
set ignorecase
set smartcase
set showmatch
set autoindent
set copyindent
set preserveindent
set shortmess-=S
set cursorline
set grepprg=rg\ --vimgrep\ --smart-case\ --follow

highlight CursorLine cterm=reverse ctermbg=White ctermfg=DarkBlue

set clipboard=unnamed

autocmd TextYankPost * call system('win32yank.exe -i --crlf', @")

function! Paste(mode)
	    let @" = system('win32yank.exe -o --lf')
	        return a:mode
endfunction

map <expr> p Paste('p')
map <expr> P Paste('P')

autocmd TextYankPost * call YankDebounced()

function! Yank(timer)
    call system('win32yank.exe -i --crlf', @")
    redraw!
endfunction

let g:yank_debounce_time_ms = 500
let g:yank_debounce_timer_id = -1

function! YankDebounced()
    let l:now = localtime()
    call timer_stop(g:yank_debounce_timer_id)
    let g:yank_debounce_timer_id = timer_start(g:yank_debounce_time_ms, 'Yank')
endfunction
