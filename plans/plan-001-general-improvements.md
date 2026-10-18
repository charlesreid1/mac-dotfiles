# Dotfiles: General Improvements Plan

## Context

The dotfiles at `/Users/charles/dotfiles/mac/` have accreted over many years. The
largest files (`.aliases` at 439 lines, `.vimrc` at 614 lines, `.bash_profile`
at 165 lines) mix live config with commented-out cruft, copy-pasted scrapbook
sections (mathias, spf13, Github Maximum Awesome, Reddit), and duplicated
settings that conflict with each other. Several files are dead (`.screenrc`,
`.curlrc`, likely `.gdbinit`), pathogen is silently disabled so no vim plugins
actually load, and a handful of aliases are broken outright. This plan proposes
a reorganization that matches the user's evident style (short mnemonic aliases,
verb-prefix families, multi-host workflow) plus a prioritized cleanup list.

Sources: full read of every dotfile and support script. Line references below
are to the current files on disk.

---

## Part 1 — Reorganization Proposal

### Proposed layout

```
~/dotfiles/mac/
├── README.md                       # updated to match reality (see Part 2)
├── bootstrap.sh                    # renamed from pre_bootstrap.sh
├── shell/
│   ├── bashrc                      # interactive guard restored; sources the rest
│   ├── bash_profile                # login shell; sources bashrc
│   ├── env                         # was .exports + env from bash_profile
│   │                               # PATH, EDITOR, PAGER, HIST*, LANG, GO*, LESS_TERMCAP_*
│   ├── prompt                      # was .bash_prompt (colors defined AND exported here)
│   ├── functions                   # curated, non-mathias
│   └── aliases.d/                  # split of .aliases (see below)
│       ├── 00-core.sh              # ll, la, mk, .., ., editor, reload
│       ├── 10-git.sh               # g, gs, gd, gco, gp...
│       ├── 20-tmux.sh              # tns, tnw, taw, trw
│       ├── 30-ssh.sh               # host shortcuts + tunnels (generated helper)
│       ├── 40-python.sh            # py, ip, pp (fixed), venv helpers
│       ├── 50-llm.sh               # claude/gemini/deepseek/opencode/omo-*
│       ├── 60-bio.sh               # snakemake shortcuts
│       └── 99-typos.sh             # mdkir, celar, cealr, lll (intentional)
├── hosts.d/
│   ├── maya.sh                     # was the maya block in bash_profile
│   ├── kraken.sh
│   ├── cronus.sh
│   ├── aptos.sh
│   ├── randal.sh
│   ├── bear.sh
│   ├── emmett.sh
│   ├── seawater.sh
│   └── charlesreid1.party.sh
├── vim/
│   ├── vimrc                       # restructured (see below)
│   ├── gvimrc
│   ├── colors/
│   └── setup.sh                    # migrated to vim-plug
├── tmux/
│   ├── tmux.conf
│   └── session1.conf               # or delete if scripts/devtmux covers it
├── git/
│   ├── gitconfig
│   ├── gitconfig_ch4zm             # already referenced by includeIf
│   ├── gitconfig_charlesreid1      # currently MISSING — create or drop the include
│   ├── gitignore_global
│   └── gitattributes
├── secrets/                        # gitignored
│   └── api_keys.sh                 # replaces the raw sources in .bash_profile
├── scripts/
└── legacy/                         # move, don't delete yet
    ├── screenrc
    ├── curlrc
    └── gdbinit
```

### Rationale for the big moves

- **Split `.aliases`.** 439 lines in one file is unmaintainable. `aliases.d/` sourced by glob keeps loading trivial (`for f in shell/aliases.d/*.sh; do . "$f"; done`) and numeric prefixes give explicit load order.
- **`hosts.d/` autoloader.** Replace the inline `if [[ $(hostname) == maya* ]]` blocks with `[ -r hosts.d/$(hostname -s).sh ] && . "$_"`. New machines = new file, no merges into `.bash_profile`.
- **Consolidate env into one file** (`shell/env`). Today `HISTSIZE`, `EDITOR`, `HISTTIMEFORMAT` are set in both `.bash_profile` and `.exports` with conflicting values. One file, sourced once.
- **Move color definitions into `shell/env` (and export them)** so `LESS_TERMCAP_md=$yellow` in `.exports` actually resolves — it doesn't today.
- **`legacy/` instead of `rm`.** Keeps restore option, makes dead things obvious.

### `.vimrc` restructure — top-to-bottom flow

```
1.  Leader                          " let mapleader=',' FIRST, before any mapping
2.  Plugin manager bootstrap        " vim-plug (replaces broken pathogen)
3.  Plugin list                     " Plug '...'
4.  General settings                " nocompatible, encoding, filetype
5.  UI                              " number, ruler, showcmd, cursorline, colorscheme
6.  Editing behavior                " tabs, indent, backspace, wrap
7.  Search                          " incsearch, hlsearch, ignorecase, smartcase (each ONCE)
8.  Performance                     " synmaxcol, maxmempattern, redrawtime, lazyredraw
9.  Files & backup                  " backupdir, undodir, autoread
10. Filetype autocmds               " snakemake pattern FIXED, python, go, markdown
11. Mappings                        " grouped: navigation, windows, buffers, leader-*
12. Plugin config                   " vim-go, jedi, black
13. Local override                  " if filereadable('~/.vimrc.local') | source | endif
```

---

## Part 2 — Improvements List

Prioritized: **FIX** = broken today, **CLEAN** = works but cruft, **CONSIDER** = further quality.

### FIX — broken today

**shell**
- `.bashrc:1` restore the `[[ $- != *i* ]] && return` guard — non-interactive shells currently load the full profile.
- `.bash_profile:10-18` `export EDITOR GOROOT GOPATH` — set but unexported.
- `.bash_profile` `GOROOT=$HOME/go` is wrong (same as `GOPATH`); delete or set to `$(go env GOROOT)`.
- `.exports` `LESS_TERMCAP_md=$yellow` — `$yellow` is defined in `.bash_prompt` but never exported, so it's empty at export time. Define colors in `shell/env` and export.
- `.aliases:118,120` remove duplicate `lt` (first uses undefined `$LS`).
- `.aliases:62,343` remove `h='hostname'` duplicate (keep `h=history`).
- `.aliases:75` `alias dh='dh -kTh'` is recursive; change to `alias dh='df -kTh'`.
- `.aliases:298,302` `tvsp` / `thsp` missing the `alias` keyword — silently do nothing.
- `.aliases:17` `claude-sonnet-4-6` is not a real model id — remove or fix.
- `.functions` `server` and `json` use Python 2. Change to `python3 -m http.server` and `python3 -m json.tool` (or `jq .`).
- `.functions:143-149` `v()` silently overrides `.aliases`'s `v='vim'` — pick one.

**vim**
- `.vimrc:157` uncomment `execute pathogen#infect()` OR migrate to vim-plug (recommended, see Part 3). Right now vim-go / jedi-vim / black are installed by `vim_setup.sh` but never loaded.
- `.vimrc:386` move `let mapleader=','` to the top, before any `<Leader>` mapping.
- `.vimrc:210` `au BufNewFile,BufRead set syntax=snakemake` is missing its file pattern — sets snakemake syntax on ALL files. Change to `au BufNewFile,BufRead *.smk,Snakefile setfiletype snakemake`.
- `.vimrc:599-602` bubble-line mappings shadow `<C-j>`/`<C-k>` window nav at 401-404. Rebind bubbles to `<Leader>j`/`<Leader>k` or `[e`/`]e` (unimpaired style).
- `.gvimrc` `guicursor` conflicts with `.vimrc:144`. Pick one, keep in `.vimrc`.
- `vim_setup.sh:27` Black plugin URL uses `master`; upstream default is `main`.

**tmux**
- `.tmux.conf:113` `bind k kill-window` collides with `bind k select-pane -U` at line 61 — vim-style up-pane is broken. Rebind kill to `bind K` (capital, verb-family convention).
- `.tmux.conf:58,134` `bind s` split vs source-file. Move source-file to `bind R` (reload).

**git**
- `.gitconfig:23-24,226-233` remove the duplicate `[push]` block; keep `default = simple`, drop the later `matching`.
- `.gitconfig:66,69` remove duplicate `bb` alias.
- `.gitconfig:13-14` `includeIf` points to `.gitconfig_charlesreid1` which doesn't exist — create it or drop the include (produces a warning on every git invocation under the matching path).
- `.gitconfig:20-22` delete `[filter "media"]` (pre-LFS legacy).

**bootstrap**
- `pre_bootstrap.sh` reorder: `brew_install.sh` runs LAST but `python_setup.sh` needs pyenv (from brew).
- Bash path assumption: script uses `/usr/local/bin/bash` (Intel); on Apple Silicon brew installs to `/opt/homebrew/bin/bash`. Use `command -v bash` or check both.
- Rename `pre_bootstrap.sh` → `bootstrap.sh`; fix `README.md:70` typo `pre_boostrap.sh`.

### CLEAN — works but cruft

- `.bash_profile:118-137` delete the 34-line commented-out ssh-agent block.
- `.bash_profile` gate `touch ~/.hushlogin` with `[ ! -f ~/.hushlogin ]`.
- `.bash_profile` fix mixed tab/space indent in the maya block (43-66).
- `.bash_profile:35,38` guard API-key sourcing with `[ -f ... ]`.
- `.aliases:359-427` delete the ~68-line commented mathias block.
- `.aliases:349` `alias grep='grep -i ...'` — surprising global default. Drop `-i`, keep `--color=auto`. Add `gri` for case-insensitive.
- `.aliases` `pp='python setup.py build ...'` — replace with `pip install -e .`.
- `.aliases:156-259` collapse the 10 near-identical VPN/ssh-agent blocks (see Part 3).
- `.vimrc` remove all duplicate settings: `incsearch` (131,463), `hlsearch` (129,459), `ignorecase` (134,461), `smartcase` (135,399), `ruler` (237,473), `showcmd` (398,481,515), `backspace` (142,430), `filetype plugin indent on` (6,167,217,336).
- `.vimrc` drop settings that are Vim 8+ defaults (`nocompatible`, `wildmenu`, `ttyfast`, `laststatus=2`).
- `.vimrc:547-581` delete the 20+ commented `colorscheme` lines; set one active colorscheme.
- `.gitignore` add `*.swp`, `*.swo`, `__pycache__/`, `.env`, `.env.*`, `.idea/`, `.vscode/`, `node_modules/`, `*.log`, `.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/`.
- `.gitattributes` add real defaults: `* text=auto eol=lf`, `*.sh text eol=lf`, `*.png binary`.
- Move `.screenrc`, `.curlrc`, `.gdbinit` to `legacy/` (tmux user; curlrc entirely commented; gdbinit is libstdc++ on a libc++ platform).
- Standardize script shebangs to `#!/usr/bin/env bash`; add `set -euo pipefail` to new scripts. Currently `pre_bootstrap.sh` uses `#!/bin/sh`, `bootstrap.sh` uses `#!/usr/bin/env bash`, `diff_dotfiles.sh` uses `#!/bin/bash`, `scripts/devtmux` uses `#!/bin/sh`.

### CONSIDER — further quality

- Document tmux prefix (`C-t`) in `README.md`.
- README: add sections for `.aliases`, `.functions`, `.exports`, `.gitconfig_ch4zm`, `.tmux.session1`.
- Delete `.tmux.session1` if `scripts/devtmux` covers it; otherwise document why both exist.

---

## Part 3 — Further-Improvement Suggestions

Matched to the user's evident style (short mnemonic aliases, verb-prefix families, multi-host workflow).

**1. `mktunnel` helper** — collapses the 10 near-identical VPN blocks in `.aliases:156-259`. In `shell/functions`:
```bash
mktunnel() {  # mktunnel <alias> <localport>:<host>:<remoteport> <sshhost>
  eval "alias $1='ssh -N -L $2 $3'"
}
mktunnel tun-maya    5900:localhost:5900 maya
mktunnel tun-kraken  8888:localhost:8888 kraken
```
Ten lines instead of ~80.

**2. `hosts.d/` autoloader** in `shell/env`:
```bash
host_file=~/.dotfiles/hosts.d/$(hostname -s).sh
[ -r "$host_file" ] && . "$host_file"
```

**3. Migrate pathogen → vim-plug.** Pathogen is commented out anyway, so this is a lateral move with better ergonomics: on-demand load, `:PlugUpdate`, lock file. `vim_setup.sh` becomes a one-liner curl + `vim +PlugInstall +qall`.

**4. Consistent vim leader-key families** matching the shell's verb-prefix style:
- `<Leader>g*` — git (fugitive: gs, gd, gb, gc)
- `<Leader>t*` — tabs / toggle
- `<Leader>b*` — buffers
- `<Leader>f*` — find (fzf: ff, fb, fg)
- `<Leader>w*` — windows

**5. Replace mathias holdovers** in `.functions`:
- `server` → `python3 -m http.server`
- `json` → `jq .` (add `jq` to Brewfile)
- Audit for other Python 2 / pre-Catalina assumptions.

**6. Brewfile.** Replace ad-hoc `brew install` in `brew_install.sh` with `Brewfile` + `brew bundle`. Idempotent, diffable, includes casks + mas apps.

**7. `dot` command** — dotfile ops in the user's one-letter style:
```bash
dot() { case "$1" in
  e) $EDITOR ~/.dotfiles ;;
  u) (cd ~/.dotfiles && git pull && ./bootstrap.sh) ;;
  s) (cd ~/.dotfiles && git status) ;;
  *) (cd ~/.dotfiles && git "$@") ;;
esac; }
```

**8. Symlink manager (`stow`).** Replace hand-rolled `rsync` in `bootstrap.sh` with `stow shell vim tmux git` from `~/.dotfiles`. Removes bootstrap complexity, makes per-package install/uninstall trivial, keeps `~` files as symlinks so edits go back to the repo.

**9. `shellcheck` in a pre-commit hook.** With 400+ lines of aliases and functions, `shellcheck shell/**/*.sh` will catch the next `dh='dh -kTh'` before it lands.

**10. Formalize `omo-*` / `claude-*` families.** Already verb-prefix — add a short header comment in `50-llm.sh` documenting the convention (`omo-<model>`, `claude-<variant>`) so new LLM aliases follow the pattern.

---

## Critical files to modify

- `/Users/charles/dotfiles/mac/.aliases` — split into `aliases.d/`, fix the broken/duplicate aliases first
- `/Users/charles/dotfiles/mac/.bash_profile` — extract env into `shell/env`, extract per-host into `hosts.d/`, delete dead ssh-agent block
- `/Users/charles/dotfiles/mac/.vimrc` — restructure into 13-section flow, fix snakemake autocmd, move mapleader to top, migrate pathogen → vim-plug
- `/Users/charles/dotfiles/mac/.tmux.conf` — fix `bind k` and `bind s` collisions
- `/Users/charles/dotfiles/mac/.gitconfig` — dedupe `[push]` and `bb` alias, fix broken includeIf, drop legacy `[filter "media"]`
- `/Users/charles/dotfiles/mac/pre_bootstrap.sh` — reorder brew before python, handle Apple Silicon bash path

## Verification

After each phase:
1. **Shell**: open a new terminal, run `type -a <alias>` for a sample from each `aliases.d/` file, run `env | grep -E 'PATH|EDITOR|HIST'` to confirm no duplicates/conflicts. Run `bash -n` on each sourced file.
2. **Vim**: open a `.py`, a `.go`, a `.smk`, and a plain `.txt`; confirm filetype is correct on each (the snakemake bug means `.txt` currently mis-identifies). Run `:scriptnames` to confirm plugins load. Test window nav (`<C-j>`/`<C-k>`) actually moves panes.
3. **tmux**: reload config, verify `prefix + k` selects up-pane and `prefix + K` kills window, `prefix + s` splits and `prefix + R` reloads.
4. **git**: run `git config --list --show-origin | grep push.default` to confirm one value; `cd` into a matching includeIf path and confirm no warning.
5. **Bootstrap**: dry-run on a VM or scratch user account.
