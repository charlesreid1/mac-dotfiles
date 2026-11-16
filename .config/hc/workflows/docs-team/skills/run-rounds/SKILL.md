---
name: run-rounds
description: Lead the docs-team workflow - start a drafter per document, run review and revision rounds with fresh reviewers, commit each round, and summarise for the user. Run by the lead agent in the project directory.
argument-hint: "[MAX_ROUNDS]"
---

# Lead the document rounds

You are the lead. You start and steer the other agents; you do not draft or
review yourself. The maximum number of review rounds is $ARGUMENTS, or 2 if
that is empty.

The project directory is a git repository holding `plan.md` (one `## <name>`
section per document), `corpus/`, `drafts/` and `reviews/`. Create `drafts/`
and `reviews/` if they are missing.

**Start the drafters.** Collect the document names from the `## ` headings in
`plan.md` and start one drafter per document with one command:

    hc swarm -c 'claude --plugin-dir ~/.config/hc/workflows/docs-team -n {t} "/docs-team:draft-doc {t}"' NAME1 NAME2 ...

Each drafter's tab is labelled with its document name.

**Keep a status file.** Write `status.md` with one bullet per document: its
stage (drafting, in review round N, revising for round N, done) and the
latest review verdict. Update it after every report.

**Handle reports as they arrive.** Each report reaches you as a prompt
starting `[report from NAME]`. Act on it, update `status.md`, then wait for the
next one.

* **"DOC draft ready" or "DOC revised for round N":** start round R, where R is 1
  for a new draft and N + 1 after a revision, with a fresh reviewer that has
  never seen this document:

      hc run --name DOC-rR -- claude --plugin-dir ~/.config/hc/workflows/docs-team --agent docs-team:reviewer -n DOC-rR "/docs-team:review-doc DOC R"

* **"DOC round R: 0 blocking":** the document is done.
* **"DOC round R: N blocking" with R below the maximum:** send the review back to
  the drafter, who still has the document in context:

      hc send DOC "/docs-team:revise-doc DOC R"

* **"DOC round R: N blocking" with R at the maximum:** stop; the document is done
  with open issues.

**Commit each round.** When every document has finished round R (reviewed,
and revised if needed), commit `drafts/`, `reviews/` and `status.md` with the
message `docs: round R`.

**Finish.** When every document is done, report to the user: for each
document, the rounds it took, whether blocking issues remain, and the
suggestions the drafter skipped (from the `-response.md` files).
