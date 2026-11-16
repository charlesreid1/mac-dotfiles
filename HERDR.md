# herdr crash course

herdr is a terminal multiplexer built for coding agents: tmux-like panes and
tabs, plus a sidebar that shows which agents need you. This repo sets it up
with tmux's keys (prefix `ctrl+t`) and a small wrapper, `hc`, for running one
agent per ticket.

The goal is to watch agents by exception. Many agents run at once, the sidebar
flags the few that are blocked or done, and helpers report to a lead agent
instead of to you.

## Install

* **Binary:** `curl -fsSL https://herdr.dev/install.sh | sh` (run by
  `herdr_install.sh`). It downloads the release binary for this Mac's CPU,
  checks its SHA-256, and puts it in `~/.local/bin/herdr`. Update with
  `herdr update`. Avoid `brew install herdr` on Intel Macs: it builds OpenSSL
  from source.
* **Config:** `.config/herdr/config.toml`, copied to `~/.config/herdr/` by
  `bootstrap.sh`. Reload a running herdr with prefix `R`. All defaults:
  `herdr --default-config`.
* **Wrapper:** `scripts/hc`, on PATH as `~/scripts/hc`. It needs `jq`. The
  core commands are `run`, `swarm` and `report`; `send`, `ls`, `mop` and
  `space` are conveniences over plain herdr and git commands.
* **Start:** `herdr` opens or reattaches the default session. Sessions survive
  closing the terminal, like tmux.

## The model

* **Workspace (one per repo):** the sidebar's top-level rows. `hc` names each
  workspace after the repo's main checkout, so all of a repo's tickets land in
  one workspace even when started from inside a worktree.
* **Tab (one per ticket):** each ticket's agent runs in its own tab, labelled
  with the ticket name.
* **Pane:** a split inside a tab. IDs look like `w1:p3` (workspace 1, pane 3).
* **Agent states:** herdr reads each agent's screen and marks the pane
  `blocked` (waiting on you), `working`, `done` (finished, not yet looked at),
  `idle` (finished and seen), or `unknown`.
* **Roll-up:** a blocked agent makes its tab and its workspace show as
  blocked; a done agent stays marked until you look at it. Ignore anything
  that says working.

## Keys

Press `ctrl+t`, then the key. `X` means shift+x.

* **Tabs (tmux windows):**
  * `c` new tab (asks for a name)
  * `n` / `p`, or `space` / `backspace`: next / previous tab
  * `1`..`9` jump to a tab
  * `,` rename, `X` or `&` close
* **Panes:**
  * `v`, `|` or `%` split side by side
  * `s`, `_` or `-` split stacked
  * `h` `j` `k` `l` move between panes, `tab` cycles
  * `x` close pane, `z` zoom, `r` resize mode
  * `[` copy mode (vi keys, `v` select, `y` copy); copy-on-select is on, so
    paste with Cmd+V
* **Workspaces (tmux sessions):**
  * `(` / `)` previous / next workspace
  * `w` workspace picker, `N` new workspace, `$` rename, `D` close
* **Agents (the reason to use herdr):**
  * `g` goto picker, then `b` shows only blocked agents, `d` only done ones
  * `o` jumps to the agent behind the latest notification
  * `a` / `A` next / previous agent in the sidebar's agent list, which is
    sorted blocked-and-done first
* **Other:** `d` or `q` detach, `R` reload config, `b` hide the sidebar, `S`
  settings, `e` open the scrollback in `$EDITOR`, `?` list every binding.

Where this differs from `~/.tmux.conf`:

* **`k` moves up.** In tmux, `C-t k` kills the window without asking: the later
  `bind k kill-window` overrides the `hjkl` block.
* **`s` splits.** In tmux, `C-t s` loads `~/.tmux.session1`: the later binding
  overrides the split.
* **Missing:** no `:` command prompt, no `]` paste, no layout keys (`enter`,
  `+`, `=`, `C-o`).
* **`ctrl+t` is taken.** herdr has no documented way to pass a literal `ctrl+t`
  through to the program, so Claude Code's `ctrl+t` (task list) and bash's
  transpose-characters are unreachable inside herdr, as they are inside
  tmux. Don't run herdr inside tmux: both want `ctrl+t`.

## Starting a swarm

`hc swarm` opens one tab per ticket in the current repo's workspace, without
moving your focus, and starts `claude -w TICKET -n TICKET "PROMPT"` in each.
`-w` makes Claude create its own git worktree (under `.claude/worktrees/`), so
the tickets cannot step on each other. The command is typed into the tab's
login shell, so the machine's `claude` alias from `aliases.sh` applies.

```bash
cd ~/code/myrepo
hc swarm JIRA-101 JIRA-102 JIRA-103
hc swarm -p 'Fix {t} according to the Jira spec.' JIRA-104 JIRA-105
```

For any other command, `hc run` does the same for one tab:

```bash
hc run --name lint -- npm run lint --watch
hc run --fg --name JIRA-106 -- codex "Review the diff for JIRA-106"
```

`--fg` switches to the new tab; the default leaves your focus where it is.

## Agents reporting to a lead

Start a lead agent in the repo's workspace, then ask it to run the swarm:

> Run `hc swarm JIRA-101 JIRA-102 JIRA-103`. Each helper reports back to you
> when it finishes. Collect the reports and tell me which branches are ready
> to merge.

When `hc run` runs inside a herdr pane (as it does from the lead's Bash tool),
it gives each new tab the variable `HC_LEAD` set to the lead's pane, and
`hc swarm` adds this to each helper's prompt:

> When finished, run: hc report "JIRA-101: <one-line summary>"

`hc report` types `[report from JIRA-101] ...` into the lead's prompt and
presses Enter. A report longer than one line goes to a file under
`$TMPDIR/hc-reports/`, and the lead gets the first line plus the file's path.
You read the lead's summary instead of a dozen finished tabs.

Other directions:

* **You to any agent:** `hc send JIRA-102 "also add a test"` (a tab label, an
  agent name, or a pane ID).
* **States:** `hc ls` lists every agent's state, ticket, and pane.
* **Permission prompts:** a helper asks permission before running
  `hc report`, and that shows up as blocked. To skip the prompt, allow
  `Bash(hc report:*)` in Claude's settings (the dot-claude repo).

## Tearing down

* **Close tabs:** prefix `X` on each finished tab, or prefix `D` to close the
  whole workspace.
* **Merge** the branches you approve.
* **Remove worktrees:** when a Claude session ends, it removes its worktree if
  nothing changed and asks otherwise. Remove what is left with
  `git worktree remove .claude/worktrees/JIRA-101`.
* **Prune:** `hc mop` runs `git worktree prune` and lists the agent worktrees
  that remain. Pruning only clears git's records of worktrees whose
  directories are already gone. It never deletes a directory.

## Raw herdr commands

`hc` is a thin layer over these. Every command prints JSON.

* **Make things without stealing focus:** `herdr workspace create --cwd DIR
  --label NAME --no-focus`, `herdr tab create --workspace w1 --label NAME
  --env K=V --no-focus`, `herdr pane split --direction right --no-focus`.
* **Run a command in a pane:** `herdr pane run w1:p3 "make test"` (types the
  text and presses Enter). `pane send-text` types without Enter; `pane
  send-keys w1:p3 esc` sends keys.
* **Talk to an agent:** `herdr agent prompt w1:p3 "text"` submits a prompt and
  fails if the pane is not running an agent. Add `--wait` to block until the
  agent finishes.
* **Read and wait:** `herdr pane read w1:p3 --lines 40`, `herdr agent wait
  w1:p3 --until blocked --timeout 600000`, `herdr pane wait-output w1:p3
  --regex 'passed|failed'`.
* **Inside a pane:** `HERDR_PANE_ID`, `HERDR_TAB_ID` and `HERDR_WORKSPACE_ID`
  name the pane, tab and workspace a process runs in.
* **Worktrees:** `herdr worktree create --branch NAME` makes a worktree as its
  own workspace, grouped under the repo's workspace. `hc` uses Claude's `-w`
  and tabs instead, so the repo's workspace rolls up every ticket.
* **Claude hooks:** `herdr integration install claude` adds hooks that report
  Claude's state directly instead of reading the screen. It edits Claude's
  settings, which live in the dot-claude repo, so install it there
  deliberately. Screen reading works without it.
