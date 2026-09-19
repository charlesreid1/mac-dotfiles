#!/bin/bash

echo "Making vim undo and swap dirs"
mkdir -p ~/.vim/swap \
         ~/.vim/undo

echo "Installing solarized color scheme ..."
mkdir -p ~/.vim/colors \
    && cp .vim/colors/* ~/.vim/colors/.

# No plugins. The system vim has no +python3, so black.vim can't load;
# .vimrc ships a plugin-free ,bb that shells out to `black` instead.
# black and ruff come from python_setup.sh / pyenv.
