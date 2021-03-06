#!/bin/bash
#
# Homebrew setup/install

sudo chown -R $(whoami) /usr/local/var/homebrew
sudo chmod -R g+rwx /usr/local

brew update

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils

# gettext, envsubst, and other utils
brew install gettext
brew link --force gettext

# Install some other useful utilities like `sponge`.
brew install moreutils

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils

# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed

# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q '/usr/local/bin/bash' /etc/shells; then
  echo '/usr/local/bin/bash' | sudo tee -a /etc/shells;
  chsh -s /usr/local/bin/bash;
fi;

# Install wget
brew install wget

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install joplin for note-taking
brew cask install joplin

# Install aws cli
brew install awscli

# Install more recent versions of some macOS tools.
brew install vim
brew install grep
brew install openssh
brew install screen
brew install tmux
brew install most

# Install openjdk
brew cask install adoptopenjdk

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
brew install aircrack-ng
brew install bfg
brew install binutils
brew install binwalk
brew install cifer
brew install john
brew install netpbm
brew install nmap
brew install sqlmap

#brew install hydra
#brew install dex2jar
#brew install dns2tcp
#brew install fcrackzip
#brew install foremost
#brew install hashpump
#brew install knock
#brew install pngcheck
#brew install socat
#brew install tcpflow
#brew install tcpreplay
#brew install tcptrace
#brew install ucspi-tcp # `tcpserver` etc.
#brew install xpdf
#brew install xz


# Install other useful binaries.
brew install ack
brew install git
brew install imagemagick
brew install speedtest_cli
brew install tree

#brew install exiv2
#brew install dark-mode
#brew install exiv2
#brew install git-lfs
#brew install lua
#brew install lynx
#brew install p7zip
#brew install pigz
#brew install pv
#brew install rename
#brew install ssh-copy-id
#brew install testssl
#brew install vbindiff
#brew install webkit2png
#brew install zopfli

# man pages SUUUUCK
brew install tldr
brew install cheat

# Install go stuff
brew install go
brew install goenv

# Remove outdated versions from the cellar.
brew cleanup

