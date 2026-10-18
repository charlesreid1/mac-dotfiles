# Dotfiles: Per-Machine Home Overlays Plan

## Context

Now that natty and kraken share one branch, some files belong on only one
laptop. The first is `.npmrc`, which points the `@natera` npm scope at the
corporate Artifactory. Anything at the repo root ships to both laptops. This
`.npmrc` only applies to `@natera/*` packages, so it would do nothing on
kraken, but it still shouldn't be committed at the root.

Bootstrap already handles one such file: it copies
`machines/<profile>/gitconfig` to `~/.gitconfig_machine`. This plan turns that
one-off into a per-machine `home/` overlay that gets rsynced into `~` after the
shared files.

## Layout

```
.config/dotfiles/machines/
  natty/home/.npmrc               <- the untracked root .npmrc moves here
  natty/home/.gitconfig_machine   <- was natty/gitconfig
  kraken/home/.gitconfig_machine  <- was kraken/gitconfig
  generic/home/.gitconfig_machine <- was generic/gitconfig
```

Moving the three gitconfigs into the overlay removes the special case in both
scripts. After that, any work-only or personal-only file (pip config,
`.curlrc`, etc.) just goes in that machine's `home/`.

## Changes

1. **`bootstrap.sh`**: in `doIt`, replace the `cp` with a second rsync:
   ```bash
   rsync -avh --no-perms \
       "$SCRIPT_DIR/.config/dotfiles/machines/$DOTFILES_MACHINE/home/" "$HOME/" || return 1
   ```
   Leave `--exclude-from` off this one. The `.gitconfig_machine` line in
   `bootstrap_exclude.txt` matches at any depth, so it would block the
   overlay's own copy.
2. **`bootstrap_exclude.txt`**: add `/.config/dotfiles/machines/*/home/`.
   Without it, the shared rsync would also copy every machine's overlay files
   into `~/.config/dotfiles/machines/`.
3. **`diff_dotfiles.sh`**: replace the separate `.gitconfig_machine` preview at
   the end with a second loop. It would list the overlay's files with the same
   `rsync -an --out-format '%n'` trick and preview each one with
   `preview_file`.
4. **`tests/test_machine_profiles.py`**: add checks that:
   - a natty install creates `~/.npmrc` and kraken/generic installs don't;
   - the natty preview lists `.npmrc`;
   - no path exists both in the shared files and in an overlay. The overlay
     rsync runs second, so it would silently win, and the preview would show
     both versions.
5. **`README.md`**: add `home/` to the per-profile file list and rewrite the
   "Git cannot test a hostname" paragraph so it describes the overlay instead
   of the `cp`.

## Why not an env var

You could set `NPM_CONFIG_USERCONFIG` in `natty/profile.sh` with no bootstrap
changes, but only programs started from a shell see it. npm launched by an app
opened from the Dock (VS Code, for example) would miss it, and pip and uv have
the same gap.

## Caveat

rsync never deletes, so dropping a file from an overlay or renaming a laptop's
profile leaves the old copy in `~`. That's already true for the shared files.

## Verification

```bash
python3 -B tests/test_machine_profiles.py
DOTFILES_MACHINE=natty ./diff_dotfiles.sh    # lists ~/.npmrc and ~/.gitconfig_machine
DOTFILES_MACHINE=kraken ./diff_dotfiles.sh   # lists ~/.gitconfig_machine, no ~/.npmrc
```
