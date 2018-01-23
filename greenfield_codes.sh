#!/bin/bash
#
# Prepare a codes directory,
# or, whatever you want to call it

NAME="codes"
DIR="${HOME}/${NAME}"

# Make it
mkdir -p ${DIR}
cd ${DIR}

git clone --recursive https://charlesreid1.com:3000/charlesreid1/bot-master.git bots
git clone --recursive https://charlesreid1.com:3000/charlesreid1/charlesreid1-master.git charlesreid1
git clone --recursive https://charlesreid1.com:3000/cs/cs-master.git cs
git clone --recursive https://charlesreid1.com:3000/dotfiles/dotfiles-master.git dotfiles
git clone --recursive https://charlesreid1.com:3000/kali/kali-master.git kali
git clone --recursive https://charlesreid1.com:3000/charlesreid1/pelican-master.git pelican
git clone --recursive https://charlesreid1.com:3000/rpi/pi-master.git rpi

