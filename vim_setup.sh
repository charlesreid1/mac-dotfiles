#!/bin/bash

echo "Making vim undo and swap dirs"
mkdir -p ~/.vim/swap \
         ~/.vim/undo

echo "Installing solarized color scheme ..."
mkdir -p ~/.vim/colors \
    && cp .vim/colors/* ~/.vim/colors/.

echo "Installing vim-pathogen ..."
mkdir -p \
    ~/.vim/autoload \
    ~/.vim/bundle \
    && curl -LSso \
    ~/.vim/autoload/pathogen.vim \
    https://tpo.pe/pathogen.vim

echo "Installing vim-go ..."
git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go || echo "Existing vim-go folder already found, skipping this step ..."

echo "Installing black for vim..."
mkdir -p \
    ~/.vim/plugin \
    && curl -LSso \
    ~/.vim/plugin/black.vim \
    https://raw.githubusercontent.com/psf/black/master/plugin/black.vim

echo "Installing jedi autocomplete for vim..."
git clone --recursive https://github.com/davidhalter/jedi-vim.git ~/.vim/bundle/jedi-vim || echo "Existing jedi-vim folder already found, skipping this step..."

