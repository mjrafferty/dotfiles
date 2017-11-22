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
Plugin 'terryma/vim-multiple-cursors'
Plugin 'majutsushi/tagbar'
Plugin 'tpope/vim-surround'
Plugin 'easymotion/vim-easymotion'
Plugin 'mbbill/undotree'
Plugin 'oepn/vim-easytags'
Plugin 'xolox/vim-misc'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'itchyny/lightline.vim'
Plugin 'junegunn/rainbow_parentheses.vim'
Plugin 'ervandew/supertab'
Plugin 'morhetz/gruvbox'
call vundle#end()            " required

" Misc settings
set backspace=indent,eol,start
set hidden
set history=50    " keep 50 lines of command line history
set ruler   " show the cursor position all the time
set showcmd   " display incomplete commands
set incsearch   " do incremental searching
set relativenumber  " add line numbers
set cursorline    " underlines current line
set scrolloff=3   " keeps cursor away from top and bottom edges
set wildmenu
set wildmode=full
set undofile
set undodir=$HOME/.vimfiles/undo// " where to save undo histories
set undolevels=1000 " How many undos
set undoreload=10000 " number of lines to save for undo "
set backupdir=$HOME/.vimfiles/backup//
set directory=$HOME/.vimfiles/swp//
set gdefault
set showmatch   " Show matching brackets.
set ignorecase    " Do case insensitive matching
set smartcase   " Do smart case matching
set nowrap    " Do not wrap code
set autowrite   " Automatically save before commands like :next and :make
set colorcolumn=120

" Mouse support
if has('mouse')
  set mouse=a
endif

" Indentation
set tabstop=2
set shiftwidth=2
set expandtab

" Code folding
au FileType sh let g:sh_fold_enabled=5
set foldmethod=syntax
set foldenable

" Remove trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

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

" Color scheme
colorscheme gruvbox
set background=dark
:highlight Pmenu ctermbg=blue ctermfg=white
:highlight PmenuSel ctermbg=cyan ctermfg=red
:highlight PmenuSbar ctermbg=cyan ctermfg=green
:highlight PmenuThumb ctermbg=white ctermfg=red

" This is what sets vim to use 24-bit colors. It will also work for any version of neovim
" newer than 0.1.4.
set termguicolors

"set dictionary+=/usr/share/dict/words

set tags+=~/.vim/systags

" Makes popup completion menu act more like an IDE
set completeopt=menu,longest,menuone,preview
set complete=.,w,b,u,k,kspell,s,i,d,]

"Changes the leader key to <Spacebar> for custom shortcuts
let mapleader=" "


set formatoptions=coql  " Text formating options


" Toggle Paste Mode to save indentation
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode


au FileType c,cpp,java set mps+==:;


" NERDTree plugin settings
" Closes Vim if NerdTree plugin is the only remaining buffer open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif


" ale plugin settings
let g:ale_open_list = 1
let g:ale_lint_delay = 1000
let g:ale_sh_shellcheck_options = '-s bash'


" easytags plugin settings
let g:easytags_suppress_ctags_warning = 1


" YouCompleteMe plugin settings
let g:ycm_always_populate_location_list = 1
let g:ycm_complete_in_comments = 1
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_global_ycm_extra_conf = '~/dotfiles/.vim/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
" make YCM compatible with UltiSnips (using supertab)
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']


" RainbowParentheses plugin settings
au VimEnter * RainbowParentheses
let g:rainbow#blacklist = ['grey40']
let g:rainbow#pairs = [['(', ')'], ['[', ']'],['{', '}']]


" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnippets"]


" SuperTab plugin settings
"let g:SuperTabDefaultCompletionType = '<C-n>'


" delimitMate plugin settings
let delimitMate_expand_space = 1
let delimitMate_expand_cr= 1
imap <expr> <C-n> pumvisible()
      \ ? "\<C-n>"
      \ : "<Plug>delimitMateJumpMany"
