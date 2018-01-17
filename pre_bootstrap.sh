#!/bin/sh

# Actually make the swap directory vim is going to use
mkdir -p ~/.vim/swap
mkdir -p ~/.vim/undo

# Change shell to homebrew bash
BASH="/usr/local/bin/bash"
echo "About to set shell to ${BASH}"
chsh -s ${BASH}

