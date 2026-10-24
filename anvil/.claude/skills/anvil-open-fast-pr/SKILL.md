---
name: anvil-open-fast-pr
description: "Full flow from scratch: resolves the project's branch base before any stash, asks branch type and name, creates the branch from the branch base, commits pending changes, pushes, and opens the PR as /anvil-open-pr does — GitHub with `gh` or Gitea with `tea`."
---

# Open Fast PR

Your goal is to guide the user through the **full flow**: branch creation → commit → push → Pull Request, all in a single command. This extends `/anvil-open-pr` by handling everything from the branch creation onward; the PR itself is opened as `/anvil-open-pr` opens it, on either forge.

---

## Workflow

### Step 0 — Resolve the branch base, before touching the tree

Run, from the project root, before any `git stash` or checkout:

```bash
bash ~/.claude/skills/anvil-docs/scripts/resolve-git.sh
```

It reads the `## Git` section of `.claude/rules/anvil.md` and detects what the
section doesn't declare. The answer comes in `key: value` lines; this skill uses
`base:` (the branch base) and `forge:` (`github`, `gitea` or `nenhum`).

- **Exit `2`, with `refusal:` lines:** stop here. Tell the user each reason as it
  came — it says what to declare or fix. Nothing was stashed, checked out or
  committed: the pending changes stay where they are.
- **`forge: nenhum`:** there is no forge to open a PR on. Stop and say so, with
  nothing stashed: the project closes by local merge into the branch base.
- **`forge: github`** or **`forge: gitea`:** keep `<base>`. The remote below is
  `origin`, the one the resolver reads.

---

### Step 1 — Ask for branch type and name

Ask the user **two questions in a single message**:

1. What type of branch is this? Options: `feature`, `bugfix`, `hotfix`
2. What should the branch name be? (without the prefix — e.g., `login-fix`)

Compose the full branch name as `<type>/<name>` (e.g., `hotfix/login-fix`).

> **For an anvil spec, do not name the branch by hand.** Run
> `bash ~/.claude/skills/anvil-to-spec/scripts/new-spec.sh` instead — it reserves the
> spec number atomically and produces `{tipo}/{NNN}-{nome}` plus the matching
> flat folder. This skill is for ordinary branches that are not specs.

---

### Step 2 — Create and checkout the branch from the branch base

Whatever the type, hotfix included, the new branch comes out of `<base>`. Run:

```bash
git stash
git fetch origin
git checkout <base>
git pull origin <base>
git checkout -b <branch-name>
git stash pop
```

> Never skip the checkout and pull of the branch base before creating the new one.
> If `git stash pop` results in a merge conflict, show the diff to the user and ask which version to keep before proceeding.

---

### Step 3 — Understand the pending changes

Run:

```bash
git status
git diff
```

- Read and summarize the changes for the user.
- Alert if debug code is present (`console.log`, `var_dump`, `dd()`).
- If there is nothing to commit (clean working tree), inform the user and stop.

---

### Step 4 — Commit

Stage and commit all changes:

```bash
git add -A
git commit -m "<conventional-commit-message>"
```

- Generate the commit message in Conventional Commits format (e.g., `fix(login): handle locked account redirect`).
- Show the proposed message to the user and commit.
- Do not skip hooks (`--no-verify`).

---

### Step 5 — Push the branch

```bash
git push -u origin <branch-name>
```

Confirm push succeeded before proceeding.

---

### Step 6 — Open the PR as `/anvil-open-pr` does

Load the `anvil-open-pr` skill and follow it from its Step 0, on the branch just
pushed. The PR is written there once, for both forges: the resolver's `--repo`
and, on Gitea, `--login`; the PR text; the label from the forge's list; the
assignee; the `pr create` command and where its URL comes from; the `PR:` line in
the tickets; and the URL returned to the user. One PR, to `<base>`, whatever the
type, hotfix included.

A branch created in this flow rarely carries a spec: Step 1 asks for a free name,
with no number, and the `anvil-open-pr` skips the spec parts. When it does carry
one, the `anvil-open-pr` stops while a ticket is open, and the merge guard blocks
the `pr create` until the spec is archived.

---

## Notes

- The resolver decides the branch base and the forge, before the stash; the skill never guesses them, and never stashes when it refuses.
- Never skip the branch base checkout/pull before creating the new branch.
- Never use `--no-verify` on commits.
- If the working tree is clean after branch creation, stop and inform the user — there is nothing to commit.
- If `git stash pop` causes a merge conflict, surface the diff to the user and ask which version to keep before doing anything else.
