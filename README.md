# Mac Dotfiles

Repository containing dotfiles appropriate for use on Mac laptops.

# Quick Start

Before you begin, you should review all of the
steps in this quick start, so that you understand
what will happen when you run these scripts.
Otherwise, you may lose your dotfiles!!!

Step 1: Run pre bootstrap script

```
./pre_bootstrap.sh
```

This script does the following:

* Creates an SSH key
* Installs scripts to the `~/scripts` directory
* Installs vim plugins and creates the `~/.vim` directory structure
* Changes Mac settings and defaults

It is recommended you review the `mac_settings.sh`
script before starting.

Step 2: Do a diff of dotfiles in this repository
with your existing dotfiles so that you can review
what will change in your existing dotfiles.

Step 3: Run bootstrap script

```
./bootstrap.sh
```

This script will install all of the dotfiles
in the top level of this repository into
your home directory. It will ask you for
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





