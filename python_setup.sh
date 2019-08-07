#!/bin/bash

brew install python2 python3

curl https://pyenv.run | bash

VERSION="miniconda3-4.3.30"

pyenv install ${VERSION}
pyenv global ${VERSION}
