# .vimrc refactor, September 2026

**This was a major refactor of `.vimrc` done with Claude Code** (Anthropic's CLI
agent), reviewed and approved change-by-change by the repo owner. It is recorded
here so the diff in `git log` is not a pile of unexplained magic. The commit
that introduced it is the one that added this file.

## Why

The old `.vimrc` (612 lines) had grown by accretion from spf13, sanctum.geek.nz,
Maximum Awesome and Mathias Bynens' dotfiles. It worked, but it had duplicate
settings, settings that silently cancelled each other, dead plugin config for
plugins that were never installed, and a handful of real bugs. Goal: same daily
feel, half the lines, every line earning its place.

Result: 309 lines, no tabs, every autocmd in one `augroup vimrc`, one-line
"why" comment on every setting, credits block at the top.

## Environment this was tuned against

- macOS system `/usr/bin/vim` 9.1, arm64. No `+python3`, has `+job`/`+channel`.
- iTerm2, no tmux.
- No vim plugins installed. `~/.vim/colors` (solarized), `~/.vim/undo`,
  `~/.vim/swap` only.
- `black` and `ruff` on PATH via pyenv shims.

## Bugs fixed

1. **Second `set nocompatible` undid `noesckeys`.** Re-setting `nocompatible`
   resets a batch of options as a side effect. The Esc/`O` delay was actually
   being fixed by `ttimeoutlen=5` the whole time. Kept `ttimeoutlen`, dropped
   both the duplicate `nocompatible` and `noesckeys` (which also breaks arrow
   keys in insert mode).
2. **`set` inside filetype autocmds leaked globally.** Opening a Makefile made
   every later buffer `noexpandtab textwidth=0`. All filetype settings are now
   `setlocal`.
3. **`<C-j>`/`<C-k>` and `J` were mapped twice.** Window navigation was dead,
   shadowed by the bubble-text maps at the end of the file. Dead maps removed.
4. **Markdown no-indent never fired.** It hooked filetype `mkd` (an old plugin
   name); Vim's is `markdown`. Fixed, so markdown now actually gets no
   auto-indent. Merged with the identical yaml function.
5. **Snakemake autocmd had no file pattern**, and no snakemake syntax file
   exists. Removed.
6. **JSON / markdown filetype hacks** were malformed and redundant; Vim 9 ships
   both. Removed.
7. **`set noeol` was dead** (`fixendofline` overrides it). Removed.
8. **Persistent undo was saving history for secret files.** Added a
   `BufReadPre` rule that sets `noundofile noswapfile` for credential-shaped
   paths (`~/.aws/*`, `*credentials*`, `.ssh`, `*.pem`, `*.key`, `.*_token`,
   `.env*`, `secrets.toml`, shell history, `.netrc`, `.npmrc`, `.pypirc`).
   Existing undo files for such paths on the owner's machine were pruned.
9. **Swap dir now uses `//`** so same-named files in different dirs don't
   collide.
10. **`au! FileType python`** wiped other python autocmds. Bang removed, and
    everything lives in `augroup vimrc` so re-sourcing doesn't stack duplicates.

## Removed as dead weight

- Triplicate `filetype plugin indent on`, `ruler`, `showcmd`, `backspace`;
  duplicate `hlsearch`, `incsearch`, `ignorecase`, `smartcase`, `<F1> <nop>`,
  `shortmess`, `undodir` (two different dirs; only one existed).
- `ttyfast`, `showmode` (defaults), `backupskip` (no backups enabled),
  `:CD` (redundant with `autochdir`), `<Leader>W` (duplicate of `w!!`),
  `K <nop>` (K is remapped anyway).
- All commented-out experiments: `binary`, `match Bang`, `MathAndLiquid`,
  `BgToggle`, the colorscheme list, `relativenumber`, `listchars`.
- Pathogen, vim-go, jedi and Black plugin config. None were installed, and the
  upstream `black.vim` cannot load without `+python3`. `vim_setup.sh` no longer
  tries to install them.

## Behaviour changes (deliberate, approved)

- **Bubble text** (`<C-j>`/`<C-k>`) uses `:move` instead of `dd`/`p`, so it no
  longer overwrites the unnamed register and, via `clipboard=unnamed`, the
  system clipboard.
- **Cursor shape** uses portable DECSCUSR escapes (steady bar in insert,
  steady underline in replace, steady block otherwise) instead of the
  iTerm2-only `CursorShape=` sequences; the tmux branch is gone.
- **Visual `p`** maps to Vim 9's native visual `P` (paste without yanking),
  which fixes the old `"_dP` end-of-line glitch.
- **`j`/`k` to `gj`/`gk`** is now normal + visual only, so `dj`/`dk` are no
  longer rewired in operator-pending mode.
- **Fat-finger `WW WQ QQ XX`** are `nnoremap` (normal mode only). Visual `X`
  is no longer hijacked. The `:W :Wq :Q` typo commands are unchanged.
- **Typo abbreviations** are `iabbrev` (insert mode only), so they no longer
  expand on the `:` command line.

## New: `,bb` runs Black (python buffers only)

Plugin-free, since this vim has no `+python3`.

- `,bb` in normal mode formats the whole buffer.
- `,bb` on a visual selection formats only those lines, in context, using
  `black --line-ranges`. This replaces the old macchiato trick.
- A syntax error shows Black's message and leaves the buffer untouched.
- The whole format is one undo step.
- `--stdin-filename` is passed so Black finds the project's `pyproject.toml`.

Future option, noted in the file: ALE (dense-analysis/ale) via Vim's native
`~/.vim/pack` for live ruff linting, and `ruff format --range` as a faster
drop-in for black.

## How it was verified

Headless `vim -es` runs against the new file: zero load errors; effective
values of `ttimeoutlen`, `undodir`, `directory`, `textwidth`, `backspace`
checked; `:verbose nmap` shows one source per mapping; open Makefile then
`:enew` confirms no `noexpandtab` leak; `.md`/`.yaml`/`.py`/`.go` scratch files
confirm per-filetype settings; a fake credentials file confirms `noundofile`;
`,bb` exercised in whole-buffer, visual-range and syntax-error modes;
`diff_dotfiles.sh` reports no drift.
