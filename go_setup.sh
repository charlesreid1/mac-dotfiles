#!/bin/bash

brew install go

git clone https://github.com/syndbg/goenv.git ~/.goenv

VERSION="1.11.13"
#VERSION="1.12.9"

goenv install $VERSION
goenv global $VERSION
