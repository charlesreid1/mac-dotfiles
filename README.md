# Mac Dotfiles

Repository containing dotfiles appropriate for use on Mac laptops.

# Quick Start

Before you begin, you should review all of the
steps in this quick start, so that you understand
what will happen when you run these scripts.
Otherwise, you may lose your dotfiles!

## Step 1: Pre-Bootstrap

Step 1: Run pre bootstrap script:

```
./pre_bootstrap.sh
```

This script does the following:

* Creates an SSH key
* Installs scripts to the `~/scripts` directory
* Installs vim plugins and creates the `~/.vim` directory structure
* Changes Mac settings and defaults
* Installs and configures python (we use [pyenv](https://github.com/pyenv/pyenv)
  to install and manage multiple versions of Python
  side-by-side)
* Installs Homebrew (the Mac package manager)
* Installs useful packages using Homebrew
* Sets bash as the default shell (happens after
  the Homebrew version of bash has been installed)

It is recommended you review the settings that will
be changed on your Mac (`mac_settings.sh`) and the
software that will be installed (`brew_install.sh`)
before you run any scripts.

## Step 2: Bootstrap

The bootstrap script will do a diff between your
dotfiles and the new dotfiles, so you can see
all the changes that you will lose (in red) and
all of the new content (in green).

If there are many changes, do the diff manually by
running the script:

    ./diff_dotfiles.sh

Otherwise, run the bootstrap script, review the 
changes, and type "y" or "yes":

    ./bootstrap.sh

Again, the bootstrap script will ask you for your
confirmation before overwriting your files,
but **you _will_ lose unsaved changes in your
existing dotfiles**!

# How Does This Repo Work?

This repository contains dotfiles in the top
level of the repository. These dotfiles are
installed using the `bootstrap.sh` script.
That's the main purpose of the repository.

But because there are a lot of supplementary
things to do when customizing a new or existing
Mac, we have the `pre_boostrap.sh` script to
perform those tasks.

We recommend you open the scripts and read them
to see what they do.
