#!/bin/bash

echo Installing vim-pathogen ...
mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

echo Installing vim-go ...
git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go || echo "Existing vim-go folder already found"

echo Installing vim-colors-solarized ...
git clone git://github.com/altercation/vim-colors-solarized.git ~/.vim/bundle/vim-colors-solarized || echo "Existing vim-colors-solarized folder already found" 
