" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

"""""""""""""""""""""""""""""
"     Begin Plugin load     "
"""""""""""""""""""""""""""""

" set the runtime path to include Vundle and initialize
filetype off                            " required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'w0rp/ale'
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
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'xolox/vim-misc'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'
Plugin 'itchyny/lightline.vim'
Plugin 'junegunn/rainbow_parentheses.vim'
Plugin 'morhetz/gruvbox'
Plugin 'sheerun/vim-polyglot'
Plugin 'junegunn/fzf.vim'
call vundle#end()                       " required

"-------------------------
"----- End Plugin load ---
"-------------------------

"""""""""""""""""""""""""""""
"     Begin Vim Settings    "
"""""""""""""""""""""""""""""

" Misc settings
set backspace=2                         " Controls backspace behavior
set hidden
set history=50                          " keep 50 lines of command line history
set ruler                               " show the cursor position all the time
set showcmd                             " display incomplete commands
set incsearch                           " do incremental searching
set relativenumber                      " add line numbers
set cursorline                          " underlines current line
set scrolloff=3                         " keeps cursor away from top and bottom edges
set wildmenu
set wildmode=full
set gdefault
set showmatch                           " Show matching brackets.
set ignorecase                          " Do case insensitive matching
set smartcase                           " Do smart case matching
set nowrap                              " Do not wrap code
set autowrite                           " Automatically save before commands like :next and :make
set hlsearch
set laststatus=2
set smartindent
set smarttab
set clipboard=autoselect

" Undo settings
set undofile
set undolevels=1000                     " How many undos
set undoreload=10000                    " number of lines to save for undo "

" Vim file locations
set undodir=$HOME/.vimfiles/undo//      " where to save undo histories
set backupdir=$HOME/.vimfiles/backup//
set directory=$HOME/.vimfiles/swp//

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
let php_folding=1

syntax enable
filetype plugin indent on
set omnifunc=syntaxcomplete#Complete

" Color scheme
colorscheme gruvbox
set background=dark
:highlight Pmenu ctermbg=blue ctermfg=white
:highlight PmenuSel ctermbg=cyan ctermfg=red
:highlight PmenuSbar ctermbg=cyan ctermfg=green
:highlight PmenuThumb ctermbg=white ctermfg=red
:highlight Normal ctermbg=none

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

" Clear search highlighting by pressing Enter
nnoremap <cr> :noh<CR><CR>:<backspace>

"set viminfo='100,<50,s10,h,n/chroot/home/${USER}/.viminfo

"-------------------------------
"------ End Vim Settings -------
"-------------------------------

"""""""""""""""""""""""""""""""""
"     Begin Plugin Settings     "
"""""""""""""""""""""""""""""""""

" ale plugin settings
let g:ale_open_list = 1
let g:ale_lint_delay = 1000
let g:ale_sh_shellcheck_options = '-s bash'
let g:ale_linters_sh_shellcheck_exclusions = "SC1117,SC2016"

" easytags plugin settings
let g:easytags_suppress_ctags_warning = 1
let g:easytags_async=1
let g:easytags_python_enabled=1

" YouCompleteMe plugin settings
let g:ycm_always_populate_location_list = 1
let g:ycm_complete_in_comments = 1
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_global_ycm_extra_conf = '~/dotfiles/.vim/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0

" RainbowParentheses plugin settings
au VimEnter * RainbowParentheses
let g:rainbow#blacklist = ['grey40']
let g:rainbow#pairs = [['(', ')'], ['[', ']'],['{', '}']]

" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
let g:UltiSnipsSnippetDirectories=["UltiSnips", "mysnippets"]

" delimitMate plugin settings
let delimitMate_expand_space = 1
let delimitMate_expand_cr= 1

"----------------------------
"---- End Plugin Settings ---
"----------------------------

"""""""""""""""""""""""""""""
"     Begin Functions       "
"""""""""""""""""""""""""""""

" Balances tab key functionality between plugins
function! g:UltiSnips_Complete()
  call UltiSnips#ExpandSnippet()
  if g:ulti_expand_res == 0
    if pumvisible()
      return "\<C-n>"
    else
      call UltiSnips#JumpForwards()
      if g:ulti_jump_forwards_res == 0
        if delimitMate#ShouldJump()
          return delimitMate#JumpMany()
        endif
        return "\<Tab>"
      endif
    endif
  endif
  return ""
endfunction

" Same as above but for Shift-Tab
function! g:UltiSnips_Reverse()
  call UltiSnips#JumpBackwards()
  if g:ulti_jump_backwards_res == 0
    return "\<C-P>"
  endif
  return ""
endfunction

"-------------------------
"----- End Functions -----
"-------------------------

"""""""""""""""""""""""""
"     Begin Autocmds    "
"""""""""""""""""""""""""

" Calls Tab key functions when Tab or Shift-Tab is pressed
au InsertEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger     . " <C-R>=g:UltiSnips_Complete()<cr>"
au InsertEnter * exec "inoremap <silent> " . g:UltiSnipsJumpBackwardTrigger . " <C-R>=g:UltiSnips_Reverse()<cr>"

" Remove trailing whitespace on save
au BufWritePre * :%s/\s\+$//e

au FileType c,cpp,java set mps+==:;

" NERDTree plugin settings
" Closes Vim if NerdTree plugin is the only remaining buffer open
au bufenter *
      \ if winnr("$") == 1 && (exists("b:NERDTree") && b:NERDTree.isTabTree()) |
      \   q |
      \ endif

" When editing a file, always jump to the last known cursor position.
au BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif

"-------------------------
"----- End Autocmds ------
"-------------------------
