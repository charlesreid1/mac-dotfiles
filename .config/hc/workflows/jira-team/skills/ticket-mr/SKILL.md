---
name: ticket-mr
description: Take one Jira ticket from its spec to an open merge request, then report to the lead. Started by hc swarm with the ticket key as the argument.
argument-hint: TICKET
---

# Ticket to merge request: $ARGUMENTS

You are one of several agents working in parallel, each on its own ticket in
its own git worktree. Work only on ticket $ARGUMENTS and only inside this
worktree.

The steps below are a skeleton: replace them with the team's merge-request
recipe.

**Read the ticket.** Fetch $ARGUMENTS and its acceptance criteria (Jira CLI or
MCP server: fill in the command). If the spec is ambiguous, report the question
to the lead (see the last step) and wait for an answer instead of guessing.

**Implement.** Make the smallest change that meets the acceptance criteria.

**Test.** Run the project's tests (fill in the command) and fix failures your
change caused.

**Commit and push.** Commit with the ticket key at the start of the message,
then push the branch.

**Open the merge request.** Fill in the command (for example `glab mr create`
or `gh pr create`), with the ticket key in the title and a link to the ticket
in the description.

**Report.** Run exactly one command, then stop:

    hc report "$ARGUMENTS: <merge request link> <one-line summary>"

If you are stuck, report instead: `hc report "$ARGUMENTS: question: <question>"`.
