#!/usr/bin/env bash

git pull gh main;

function doIt() {
    rsync \
        --exclude-from "bootstrap_exclude.txt" \
        -avh --no-perms . ~;
    source ~/.bash_profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt;
else
    ./diff_dotfiles.sh
    echo "The changes in RED will DISAPPEAR FOREVER FROM YOUR DOTFILES."
    echo "The changes in GREEN will be ADDED TO YOUR DOTFILES."
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt;
    fi;
fi;
unset doIt;
