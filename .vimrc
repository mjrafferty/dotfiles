" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" set the runtime path to include Vundle and initialize
filetype off                  " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'w0rp/ale'
Plugin 'kien/ctrlp.vim'
Plugin 'Raimondi/delimitMate'
Plugin 'weynhamz/vim-plugin-minibufexpl'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'Valloric/YouCompleteMe'
Plugin 'Chiel92/vim-autoformat'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-surround'
Plugin 'easymotion/vim-easymotion'
Plugin 'ervandew/supertab'
Plugin 'itchyny/lightline.vim'
call vundle#end()            " required

set backspace=indent,eol,start

set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set relativenumber	" add line numbers
set cursorline		" underlines current line
set scrolloff=3		" keeps cursor away from top and bottom edges
set wildmenu
set wildmode=full
set undofile
set undodir=$HOME/.vimfiles/undo// " where to save undo histories 
set undolevels=1000 " How many undos 
set undoreload=10000 " number of lines to save for undo "
set backupdir=$HOME/.vimfiles/backup//
set directory=$HOME/.vimfiles/swp//
set gdefault
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set nowrap		" Do not wrap code
set autowrite		" Automatically save before commands like :next and :make
if has('mouse')
 set mouse=a
endif
set tabstop=2
set shiftwidth=2
set noexpandtab

au FileType sh let g:sh_fold_enabled=5
set foldmethod=syntax
set foldenable

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

if has("autocmd")

  filetype plugin indent on
  set omnifunc=syntaxcomplete#Complete

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent

endif 

colorscheme desert
set background=dark
:highlight Pmenu ctermbg=blue ctermfg=white
:highlight PmenuSel ctermbg=cyan ctermfg=red
:highlight PmenuSbar ctermbg=cyan ctermfg=green
:highlight PmenuThumb ctermbg=white ctermfg=red

"set dictionary+=/usr/share/dict/words

set tags+=~/.vim/systags

" Makes popup completion menu act more like an IDE
set completeopt=menu,longest,menuone
set complete=.,w,b,u,k,kspell,s,i,d,]

"Changes the leader key to <Spacebar> for custom shortcuts
let mapleader=" "

" Closes Vim if NerdTree plugin is the only remaining buffer open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

set formatoptions=coql	" Text formating options

let delimitMate_expand_space = 1
let delimitMate_expand_cr= 1

" Toggle Paste Mode to save indentation
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

let g:UltiSnipsExpandTrigger = '<c-j>'
let g:UltiSnipsJumpForwardTrigger='<tab>'
