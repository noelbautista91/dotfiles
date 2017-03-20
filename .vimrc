set background=dark
set number
syntax on
hi Normal ctermbg=none

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'L9'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'pangloss/vim-javascript'
Plugin 'Valloric/MatchTagAlways'
call vundle#end()
filetype plugin indent on
autocmd BufNewFile,BufRead *.html.erb set filetype=html
autocmd FileType javascript,html,ruby set tabstop=1|set shiftwidth=1|set expandtab
autocmd FileType python set tabstop=1|set shiftwidth=4|set expandtab
