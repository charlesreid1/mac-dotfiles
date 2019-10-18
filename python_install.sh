#!/bin/bash
#
# install python packages

if [ "$(id -u)" == "0" ]; then
    echo "DO NOT RUN THIS AS ROOT" 1>&2
    exit 1;
fi

PKG="numpy scipy pandas"
PKG="$PKG matplotlib seaborn jupyter ipython"
PKG="$PKG tornado pyzmq pygments pillow pelican"
PKG="$PKG flake8 black yapf pep8ify"

pip3 install ${PKG}

