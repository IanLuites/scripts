" Vundle
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Plugins
Plugin 'vim-airline/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'

Plugin 'elixir-lang/vim-elixir'

call vundle#end()
filetype plugin indent on

" Plugin Settings
let g:airline_powerline_fonts = 1
set laststatus=2
set ttimeoutlen=50

" Style
set background=dark
set t_Co=256
colorscheme molokai

syntax on
highlight Pmenu ctermbg=238 gui=bold

set number
set cursorline
highlight CursorLine ctermbg=black
