---
name: anvil-prune-branches
description: Updates the project's branch base, as the resolver gives it, fetches with prune and removes local branches whose remote tracking branch has been deleted.
---

# Prune Branches

Your goal is to synchronize the local repository with the remote by pruning stale remote-tracking refs and deleting any local branches that no longer have a corresponding remote branch.

## Workflow

### Step 1 — Resolve the branch base and the remote

Run, from the project root:

```bash
bash ~/.claude/skills/anvil-docs/scripts/resolve-git.sh
```

It reads the `## Git` section of `.claude/rules/anvil.md` and detects what the
section doesn't declare. The answer comes in `key: value` lines; this skill uses
`base:` (the branch base) and `remote:` (the URL of `origin`, or `none`). Every
value the resolver could resolve comes out, and each refusal comes as
`refusal: <field>: <reason>`, naming the field it hits — `base`, `forge` or
`login`.

- **No `base:` line:** stop here. Tell the user each `refusal: base:` reason as it
  came — it says what to declare or fix.
- **`remote: none`:** the project has no `origin`, and there is nothing to prune
  against. Stop and say so.
- Otherwise keep `<base>`, even when the resolver exits `2` with a `refusal: forge:`
  line: the forge isn't used here, and pruning is plain git, with any forge or
  none. The remote is `origin`, the one the resolver reads.

---

### Step 2 — Sync the branch base

Before anything, update the branch base so git's merge-base calculations are accurate (this prevents false "unmerged" errors on `-d`):

```bash
git fetch --prune origin
git checkout <base> && git pull origin <base>
```

Return to the original branch after pulling:
```bash
git checkout <original-branch>
```

Report any deleted remote refs shown in the fetch output.

---

### Step 3 — Find stale local branches

Run:
```bash
git branch -vv | grep ': gone]'
```

List all local branches whose upstream is marked as `gone`.

---

### Step 4 — Delete stale local branches

For each branch found in Step 3, run:
```bash
git branch -d <branch-name>
```

Use `-d` (safe delete). If a branch cannot be deleted with `-d` due to unmerged commits, **do not force-delete** — report it to the user and ask how to proceed.

---

### Step 5 — Report results

Summarize the result:
- Which remote refs were pruned
- Which branches (if any) could not be deleted and why

Then, always end with an explicit list of deleted local branches:

```
Deleted branches:
  - <branch-name>
  - <branch-name>
```

If no branches were deleted, say: `No local branches to delete.`
