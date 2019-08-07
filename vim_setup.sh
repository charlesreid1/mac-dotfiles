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

