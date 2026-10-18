# Mac Dotfiles

Repository containing dotfiles appropriate for use on Mac laptops.

# Quick Start

Both laptops use the same branch and files; machine differences are selected
automatically. You no longer need a separate `natera` branch after the unified
configuration has been merged into `main`.

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
* Creates the `~/.vim` directory structure and installs the
  solarized color scheme (no vim plugins; see below)
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

Update the checkout explicitly before installing (`git pull --ff-only` on the
shared branch). Bootstrap does **not** pull or switch branches for you.

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

After installing, open a new terminal or run `exec bash -l` to load the new
configuration. Bootstrap does not source the profile inside its installer shell.

## Machine Profiles

`.config/dotfiles/machine.sh` is the single source of machine detection. It uses
the `hostname` command and strips domain suffixes such as `.local`:

| Hostname | Profile / prompt name | Settings |
| --- | --- | --- |
| `creid-mac` (also `natty`) | `natty` | Natera AWS/Okta, Netskope certificates, Bedrock tools, Synapse, signed work commits |
| `kraken` | `kraken` | Personal AI tools and API keys, Go/Android/Spicetify, personal Git identities, unsigned commits |
| Anything else | `generic` / actual hostname | Common shell settings; no corporate or personal AI setup or default Git identity |

Common settings stay in `.bash_profile`, `.aliases`, `.exports`, `.gitconfig`,
and the other top-level dotfiles. Each laptop's differences live under
`.config/dotfiles/machines/<profile>/`:

* `profile.sh`: environment variables, tool paths, optional local secret files.
* `aliases.sh`: machine-specific aliases and functions (loaded after common aliases).
* `gitconfig`: Git identity, signing, and per-directory identity overrides.

Homebrew prefers `/opt/homebrew` on natty and `/usr/local` on kraken, falling back
to the installed prefix if necessary. Both use `main`'s newer tmux shortcuts.
Shared Ghostty, cmux, and uv configuration is retained.

Git cannot test a hostname in its config, so bootstrap copies the selected
`gitconfig` to `~/.gitconfig_machine`, which the shared `~/.gitconfig` includes.
Shell startup does not change Git configuration. Re-run bootstrap after renaming
a laptop or changing its Git profile. The existing `~/.gitconfig_eeggwall` for
`~/castles/` is still a local file, not supplied by this repository.

API keys remain in local files (`~/.synapse_api_key` on natty;
`~/.gemini_api_key` and `~/.deepseek_api_key` on kraken). Missing keys, Rust setup,
or pyenv no longer cause startup errors. Keep other private settings in
`~/.extra`, which is still loaded last among the shell dotfiles.

For testing or a renamed laptop, explicitly override detection:

```bash
DOTFILES_MACHINE=natty ./diff_dotfiles.sh
DOTFILES_MACHINE=kraken ./diff_dotfiles.sh
# Use the same override for bootstrap and future shell startup if needed.
```

Do not switch profiles inside an already configured shell: aliases and exported
variables from the previous profile may remain. Use a fresh shell/environment.

Run the isolated tests (they install only into temporary homes, not your home):

```bash
python3 -B tests/test_machine_profiles.py
```

# How Does This Repo Work?

This repository contains dotfiles in the top
level of the repository. These dotfiles are
installed using the `bootstrap.sh` script.
That's the main purpose of the repository.

Config files that live under `~/.config/` (e.g.
`~/.config/ghostty/config`) are kept at the same
path under `.config/` in this repository. The
bootstrap script's rsync creates the directories
in your home directory if they don't exist yet.

But because there are a lot of supplementary
things to do when customizing a new or existing
Mac, we have the `pre_boostrap.sh` script to
perform those tasks.

We recommend you open the scripts and read them
to see what they do.

# Notes on Large Changes

Big refactors of individual dotfiles get a standalone write-up so the git
history is not a pile of unexplained magic:

* [VIMRC_REFACTOR.md](VIMRC_REFACTOR.md): September 2026 rewrite of `.vimrc`
  with Claude Code. Bugs fixed, dead weight removed, behaviour changes,
  and the new plugin-free `,bb` Black shortcut.
