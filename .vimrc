" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start


if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
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
set gdefault
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set nowrap		" Do not wrap code
set autowrite		" Automatically save before commands like :next and :make
" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
 "set mouse=a
endif
set tabstop=2

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  set omnifunc=syntaxcomplete#Complete

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" set color scheme
colorscheme desert
set background=dark
:highlight Pmenu ctermbg=blue ctermfg=white
:highlight PmenuSel ctermbg=cyan ctermfg=red
:highlight PmenuSbar ctermbg=cyan ctermfg=green
:highlight PmenuThumb ctermbg=white ctermfg=red

" Enables the system dictionary
set dictionary+=/usr/share/dict/words

"set tags+=~/.vim/systags

" Makes popup completion menu act more like an IDE
set completeopt=menu,longest,menuone
set complete=.,w,b,u,k,kspell,k,s,i,d,]

" Enable Pathogen for maintaining plugins
call pathogen#infect()

"Changes the leader key to <Spacebar> for custom shortcuts
let mapleader=" "

"Default file for YouCompleteMe to use for C++ completion
let g:ycm_global_ycm_extra_conf = '.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'

" Closes Vim if NerdTree plugin is the only remaining buffer open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Toggles the TagList plugin with F8
nnoremap <silent> <F8> :TlistToggle<CR>

" Sets TagList to open on right side instead of left
let Tlist_Use_Right_Window=1

" Open NerdTree plugin on startup and move cursor back to main buffer
autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd p

set formatoptions=coql	" Text formating options

"YouCompleteMe plugin options
"let g:ycm_min_num_of_chars_for_completion =5
"let g:ycm_seed_identifiers_with_syntax =1 
"let g:ycm_extra_conf_globlist = ['~/bin/*']

" AutoComplPop options
"let g:acp_behaviorSnipmateLength=1

let delimitMate_expand_space = 1
let delimitMate_expand_cr= 1
