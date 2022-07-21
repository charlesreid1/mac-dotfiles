#!/bin/bash

brew install python3

rm -fr ${HOME}/.pyenv
curl https://pyenv.run | bash

PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"

#VERSION="miniconda3-4.3.30"
VERSION="3.9.13"

pyenv install -s ${VERSION}
pyenv global ${VERSION}
