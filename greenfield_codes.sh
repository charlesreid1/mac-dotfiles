#!/bin/bash
#
# Prepare a codes directory,
# or, whatever you want to call it

NAME="codes"
DIR="${HOME}/${NAME}"

# Make it
mkdir -p ${DIR}
cd ${DIR}

# Deploy some directories:
# - charlesreid1
# - bots
# - lit
# - python
# - pi
# - dotfiles
# - cs
# - ipy
# - docker
# - data-engineering
# - rubiks
# - security

mkdir charlesreid1
cd charlesreid1

git clone https://charlesreid1.com:3000/charlesreid1/atom-hammer-theme.git
git clone https://charlesreid1.com:3000/charlesreid1/coffin-spore-theme.git

git clone https://github.com/charlesreid1/charlesreid1-awesome.git

git clone https://charlesreid1.com:3000/charlesreid1/charlesreid1.com.git
git clone https://charlesreid1.com:3000/charlesreid1/charlesreid1.com-theme.git

git clone https://charlesreid1.com:3000/charlesreid1/charlesreid1-githubio-theme.git
git clone https://github.com/charlesreid1/charlesreid1.github.io.git









