#!/bin/bash

## The short version:
#find . -type f -maxdepth 1 -name ".*" | xargs -t -n1 -I% diff % ~/%

# The (more careful) loop version:
# Covers top-level dotfiles and files inside dot-directories (.config, .vim)
for file in $(find . -path ./.git -prune -o -type f -path "./.*" ! -name ".DS_Store" -print); do
    if [[ -f ~/$file ]]; then
        echo "------------"
        echo "$file exists in home directory, calculating diff..."
        $(which git) diff --no-index --exit-code ~/$file $file && echo "No differences in $file!"
        # order is important - home file first, shows changes to be deleted in red
    fi
done

