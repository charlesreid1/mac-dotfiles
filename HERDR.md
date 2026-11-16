# herdr crash course

herdr is a terminal multiplexer built for coding agents: tmux-like panes and
tabs, plus a sidebar that shows which agents need you. This repo sets it up
with tmux's keys (prefix `ctrl+t`), a small wrapper, `hc`, for running one
agent per work item, and two example workflows built on Claude plugins.

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

With `-c`, you give the whole command line and `{t}` stands for each item.
This is how the workflows below start their agents:

```bash
hc swarm -c 'claude --plugin-dir ~/.config/hc/workflows/jira-team -w {t} -n {t} "/jira-team:ticket-mr {t}"' JIRA-101 JIRA-102
```

Item names may use letters, digits, `.`, `_` and `-`, since each one becomes a
tab label, a worktree name and part of a command line.

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

When `hc run` or `hc swarm` runs inside a herdr pane (as it does from the
lead's Bash tool), it gives each new tab the variable `HC_LEAD` set to the
lead's pane. Without `-c`, `hc swarm` also adds this to each helper's prompt:

> When finished, run: hc report "JIRA-101: <one-line summary>"

With `-c`, the recipe the helper follows says when and what to report.

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

## Workflows

A workflow is a repeatable way of splitting a job across agents. Every
workflow answers the same five questions:

* **Unit:** what gets one tab each (a ticket, a document).
* **Recipe:** the steps each agent follows, written once as a Claude skill.
* **Isolation:** how the agents avoid colliding (a git worktree each, or a
  separate output file each).
* **Reply:** what each agent reports to the lead with `hc report`. A report is
  one line; real content lives in files and the report names the file.
* **Lead:** what the lead does with the reports: collect them once, or run
  rounds that send work back.

Two workflows ship with this repo, under `.config/hc/workflows/` (installed
to `~/.config/hc/workflows/` by bootstrap). The first is a single round, the
second runs repeated rounds, so between them they show both shapes.

### Roles and recipes are Claude plugins

A workflow's recipes and roles live in a Claude Code plugin: a folder that
Claude loads for one session with `--plugin-dir`. Nothing is installed
globally, so a session sees a workflow's skills only when it was started for
that workflow.

```
docs-team/
  .claude-plugin/plugin.json     the plugin's name
  skills/draft-doc/SKILL.md      a recipe
  skills/review-doc/SKILL.md
  agents/reviewer.md             a role
```

* **A recipe is a skill.** A plugin's skills are named after the plugin, so
  `skills/draft-doc` becomes `/docs-team:draft-doc`. Putting the skill at the
  start of the prompt runs it, and the text after it reaches the skill as
  `$ARGUMENTS`:
  `claude --plugin-dir ~/.config/hc/workflows/docs-team "/docs-team:draft-doc intro"`.
  The same works through `hc send`, so a lead can hand an agent its next step:
  `hc send intro "/docs-team:revise-doc intro 1"`.
* **A role is an agent definition.** `--agent docs-team:reviewer` starts the
  session as the role in `agents/reviewer.md`: its own instructions, tools and
  model. The role's text replaces Claude Code's built-in system prompt, so
  use roles where a narrow job is the point (a reviewer that only reads and
  writes one file) and leave them off for agents that write code.
* **Roles do not carry skills.** An agent definition can list `skills:` to
  preload, but that list has no effect when the agent is the whole session
  (`--agent`). Tested with Claude Code 2.1.318: the session started as the
  role and did not have the listed skill's content. So always name the
  recipe in the prompt, as above; a session started with `--agent` still runs
  any skill named that way.
* **Check a plugin** with `claude plugin validate DIR`.

### Workflow one: tickets to merge requests

* **Unit:** one ticket per tab, labelled with the ticket key.
* **Recipe:** `jira-team:ticket-mr`: read the ticket, implement, test, commit,
  push, open the merge request, report. The shipped skill is a skeleton;
  replace its steps with the team's merge-request recipe.
* **Isolation:** Claude's `-w` gives each ticket its own worktree.
* **Reply:** `JIRA-101: <merge request link> <summary>`, or a question if the
  spec is unclear.
* **Lead:** collects the links, answers questions with `hc send`, and tells you
  which merge requests are ready to review.

Start a lead in the repo's workspace (a plain `claude` in its first tab) and
tell it:

> Run `hc swarm -c 'claude --plugin-dir ~/.config/hc/workflows/jira-team -w {t} -n {t} "/jira-team:ticket-mr {t}"' JIRA-101 JIRA-102 JIRA-103`.
> Answer questions from the reports if the tickets settle them; otherwise ask
> me. When every ticket has reported, list the merge requests with a
> one-line summary each.

### Workflow two: corpus to reviewed documents

Agents draft technical documents from source material, independent reviewers
check them, and drafts go back for revision until the reviews are clean or a
round limit is reached.

The project is a git repository laid out like this:

* **`plan.md`:** one `## <name>` section per document, giving its reader,
  purpose and outline. The section names become the tab names.
* **`corpus/`:** the source material, the only source of facts.
* **`drafts/<name>.md`:** written by that document's drafter.
* **`reviews/<name>-r<round>.md`:** written by that round's reviewer, with the
  drafter's answer in `reviews/<name>-r<round>-response.md`.
* **`status.md`:** the lead's running record of where each document stands.

The five answers:

* **Unit:** one document per drafter tab.
* **Recipes:** `draft-doc`, `review-doc`, `revise-doc`, and `run-rounds` for
  the lead.
* **Isolation:** each agent writes only its own files, so no worktrees are
  needed and only the lead commits.
* **Reply:** `intro draft ready`, `intro round 1: 2 blocking`,
  `intro revised for round 1`.
* **Lead:** runs the rounds, below.

The rounds:

* **Drafting:** the lead starts one drafter per document with `hc swarm -c`.
  Drafters stay open for the whole run, so each keeps its document in
  context between rounds.
* **Review:** when a draft is ready, the lead starts a new reviewer tab
  (`intro-r1`) with the `reviewer` role. A fresh reviewer each round reads the
  draft cold, without the drafter's reasoning or an earlier reviewer's
  opinions.
* **Revision:** if the review found blocking issues, the lead sends the drafter
  `/docs-team:revise-doc intro 1` with `hc send`. When the drafter reports
  back, the next round's reviewer starts.
* **Stopping:** a document is done when a review finds nothing blocking, or
  after the round limit (default 2) with its open issues listed.
* **Record:** the lead commits after each round (`docs: round 1`), so git
  holds every draft and review.

To run it, open a tab in the project directory and start the lead with the
plugin:

```bash
claude --plugin-dir ~/.config/hc/workflows/docs-team -n lead "/docs-team:run-rounds 2"
```

### Making a new workflow

* **Answer the five questions** first, in a few lines each.
* **Copy a plugin:** start from `docs-team` (rounds) or `jira-team` (one
  pass), rename the folder, and set the new name in
  `.claude-plugin/plugin.json`.
* **Write the recipes:** each one names its inputs, the one file or branch it
  may change, and ends with exactly one `hc report` command in a fixed
  format. The lead reads those reports, so the format is the interface
  between them.
* **Add roles** only where an agent should be narrower than a normal Claude
  session, such as a reviewer that must not edit.
* **Write the lead's recipe:** how to start the workers (`hc swarm -c`), what
  each report means and what to do next, when to stop, what to commit, and
  what to tell you at the end.
* **Validate** with `claude plugin validate`, then try it on two items before
  twenty.

### Why not Claude Code's agent teams

Claude Code has a built-in "agent teams" feature with a lead, teammates and
messaging. It is experimental and off by default, it ignores an agent
definition's `skills:` list, and its split-pane view needs tmux or iTerm2, so
teammates would not show in herdr's sidebar. herdr plus `hc` uses only
ordinary Claude sessions and plain herdr commands, and every worker is a tab
whose state you can see.

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
