---
name: anvil-grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the frontier in **blocks** of at most 10 questions. A frontier of 10 or fewer is one block, never padded with questions whose prerequisites are still open. If the caller asks for one question at a time, every block holds one question. Before the first block, count the known decisions in the tree and announce "about N questions"; when an answer opens new branches and the count rises, announce the new estimate at the start of the next block. Then wait for the user's answers before the next block.

Ask each block with the `AskUserQuestion` tool (`request_user_input` in Codex), in as many consecutive calls as the harness limit requires: in Claude Code, at most 4 questions per call and 2 to 4 options per question; where the tool takes the whole block, one call. Never shrink a block to fit one call. Shape every question like so:

```
header:   <title, at most 12 characters>
question: <one or two sentences>
options:
  1. <recommended answer>, marked recommended — description: <one line of why>
  2. <alternative>
  3. <alternative>
  custom: the tool's own free-text option when it has one ("Other");
          otherwise an explicit "Write my own answer" option
```

Every question carries both, exactly once:

- **The recommended option**, listed first. Mark it the way the tool does: its `recommended` field when it has one, otherwise " (Recommended)" at the end of the label, never both. With no opinion of your own, recommend the most conservative option and say so in the why.
- **The custom option**, for the user to write their own answer. Use the tool's native one when it offers it, and don't add a second. When you add it yourself, it takes one of the option slots: under a limit of 4 options, at most 3 alternatives remain.

An open question, such as a name or a number, becomes your suggested value as the recommended option, plus the custom option.

Without the tool, or when the call fails because the harness mode doesn't offer it, send the block as compact text, one line per question:

```
1. <title> — a) <option> b) <option> x) write your own  ➡️ a: <why>
2. <title> — a) <option> b) <option> c) <option> x) write your own  ➡️ b: <why>
```

The user answers `1a 2c 3b`, or `3x: <text>` for a custom answer. Anything that matches no letter is the custom answer to that question.

After each block, record its decisions on disk, then show them in chat, one line per decision. The record is `grill-<slug>.md`, where `<slug>` is kebab-case from the grill's subject. On a spec branch, `{type}/{NNN}-{name}`, it goes in the `discovery/` folder of the spec whose folder under `docs/specs/` starts with that `{NNN}`; anywhere else, in `docs/discovery/`. Create the folder with the first record. The file is append-only: each block adds a `## Bloco N` section with one line per question, giving its title, the decision (a custom answer is the decision as the user wrote it), and whether your recommendation was accepted (only picking the recommended option counts as accepted). Write the file; never commit it. When a record for the same subject already exists and the conversation doesn't hold its decisions, as in a new session or after compaction, read it before the next block: a recorded question is settled and is not asked again, and the next section continues its numbering.

When the frontier is empty, the confirmation of a shared understanding is one last prompt, through the same tool or the fallback: a summary of every decision, with the options "confirm" (recommended), "adjust", and the custom option. "Adjust" asks which decision to reopen and goes back to that branch. That question, and any other you ask on the way, is shaped like a block question: one option marked recommended, the way the tool marks it, plus the custom option. "Confirm" appends a `## Confirmação` section with the confirmed summary to the record.

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
