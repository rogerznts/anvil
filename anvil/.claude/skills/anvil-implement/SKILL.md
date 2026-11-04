---
name: anvil-implement
description: "Implement a piece of work based on a spec or set of tickets."
---

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "anvil-tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with "anvil-code-review" to review the work. Append its ready-to-paste `Review:` line to the ticket. On P1, set `Status: claimed`, commit the review record, and return to the work; otherwise keep `Status: resolved`. Put actionable P2/P3 findings under `## Comments` with their class and consequence. Never open a new round just to clear P2/P3.

Commit your work to the current branch.
