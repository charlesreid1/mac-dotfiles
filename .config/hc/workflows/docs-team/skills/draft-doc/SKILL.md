---
name: draft-doc
description: Write the first draft of one document from the project's corpus and plan, then report to the lead. Started by the docs-team lead with the document's name as the argument.
argument-hint: DOC
---

# Draft: $ARGUMENTS

You are the drafter for the document named $ARGUMENTS. Other agents draft the
other documents in parallel and separate reviewers will check your work, so
touch only your own file.

The project directory holds:

* `plan.md`: one `## <name>` section per document with its reader, purpose
  and outline.
* `corpus/`: the source material. Treat it as read-only and as the only
  source of facts.
* `drafts/`: one file per document.
* `reviews/`: reviewers' notes, one file per document per round.

**Read the plan.** Read the `## $ARGUMENTS` section of `plan.md`.

**Read the corpus.** Read the files in `corpus/` that bear on this document.

**Write the draft.** Write `drafts/$ARGUMENTS.md`, following the outline and
writing for the reader named in the plan. Every factual claim must come from
the corpus; cite the file it came from, for example `(corpus/api-spec.md)`.
Where the corpus is silent, say so in the draft rather than inventing.

**Report.** Run exactly one command, then wait:

    hc report "$ARGUMENTS draft ready: drafts/$ARGUMENTS.md"

The lead may later ask you to revise this draft; keep your context.
