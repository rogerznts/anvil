# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`docs/architecture/context.md`**, or
- **`docs/architecture/context-map.md`** if it exists: it points at one `CONTEXT.md` per context. Read each one relevant to the topic.
- **`docs/architecture/adr/`**: read ADRs that touch the area you're about to work in. In multi-context repos, also check `src/<context>/docs/adr/` for context-scoped decisions.

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. The `/anvil-domain-modeling` skill (reached via `/anvil-grill` and `/improve-codebase-architecture`) creates them lazily when terms or decisions actually get resolved.

## File structure

Single-context repo (most repos):

```
/
├── docs/
│   └── architecture/
│       ├── context.md
│       └── adr/
│           ├── 0001-event-sourced-orders.md
│           └── 0002-postgres-for-write-model.md
└── src/
```

Multi-context repo (presence of `docs/architecture/context-map.md`):

```
/
├── docs/
│   └── architecture/
│       ├── context-map.md
│       └── adr/                       ← system-wide decisions
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← context-specific decisions
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `docs/architecture/context.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal: either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/anvil-domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders), but worth reopening because…_
