---
name: anvil-implement
description: "Implement a piece of work based on a spec or set of tickets."
---

Implement the work described by the user in the spec or tickets.

Use /anvil-tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /anvil-code-review. Append its ready-to-paste `Review:` line to the ticket. On P1, set `Status: claimed`, commit the review record, and return to the work; otherwise keep `Status: resolved`. Put actionable P2/P3 findings under `## Comments` with their class and consequence. Never open a new round just to clear P2/P3.

Commit your work to the current branch.
