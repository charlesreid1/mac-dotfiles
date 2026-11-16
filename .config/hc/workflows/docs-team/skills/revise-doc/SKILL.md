---
name: revise-doc
description: Revise one draft to answer a review, then report to the lead. Sent by the lead to the document's drafter with the document name and round number.
argument-hint: DOC ROUND
---

# Revise: $ARGUMENTS

The arguments are the document name and the round number, in that order:
$ARGUMENTS. Below, DOC and ROUND stand for them.

**Read the review.** Read `reviews/DOC-rROUND.md`.

**Revise.** Fix every blocking issue in `drafts/DOC.md`. Take the suggestions
that make the document better for its reader and skip the rest. Every new
claim still needs a corpus citation.

**Answer the review.** Write `reviews/DOC-rROUND-response.md`: for each
blocking issue, one line saying what changed; then the suggestions you
skipped, each with its reason.

**Report.** Run exactly one command, then wait:

    hc report "DOC revised for round ROUND"
