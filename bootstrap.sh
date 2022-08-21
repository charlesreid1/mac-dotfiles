#!/usr/bin/env bash

git pull gh main;

function doIt() {
    rsync \
        --exclude ".git" \
        --exclude ".gitignore" \
        --exclude ".DS_Store" \
        --exclude "bootstrap.sh" \
        --exclude "brew_install.sh" \
        --exclude "diff_dotfiles.sh" \
        --exclude "go_install.sh" \
        --exclude "go_setup.sh" \
        --exclude "mac_settings.sh" \
        --exclude "pre_bootstrap.sh" \
        --exclude "python_install.sh" \
        --exclude "python_setup.sh" \
        --exclude "scripts_setup.sh" \
        --exclude "set_machine_name.sh" \
        --exclude "vim_setup.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
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
