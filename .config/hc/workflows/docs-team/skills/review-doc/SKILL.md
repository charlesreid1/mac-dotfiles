---
name: review-doc
description: Review one draft against the corpus and plan and write a review file, then report to the lead. Arguments are the document name and the round number.
argument-hint: DOC ROUND
---

# Review: $ARGUMENTS

The arguments are the document name and the round number, in that order:
$ARGUMENTS. Below, DOC and ROUND stand for them.

**Read.** Read the `## DOC` section of `plan.md`, the draft `drafts/DOC.md`,
and the corpus files it cites or should cite. If earlier rounds exist
(`reviews/DOC-r*.md`), read them to see what was already raised.

**Check.** For each factual claim, find it in the corpus. Check that the draft
covers the plan's outline and works for the reader the plan names.

**Write the review.** Write `reviews/DOC-rROUND.md`. Its first line is
`Verdict: N blocking`, where N counts the blocking issues. Then two lists:

* **Blocking:** problems that would mislead or fail the reader: claims the
  corpus contradicts or does not support, missing outline items, passages the
  reader could not follow.
* **Suggestions:** everything else worth changing.

For each issue, quote the passage, say what is wrong, and say what would fix
it. Do not edit the draft.

**Report.** Run exactly one command, then stop:

    hc report "DOC round ROUND: N blocking (reviews/DOC-rROUND.md)"
