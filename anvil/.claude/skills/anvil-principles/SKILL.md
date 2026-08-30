---
name: anvil-principles
description: "As 21 princípios de engenharia do pstack — quando cada um se aplica e o que ele muda na decisão. Use ao aplicar um princípio citado por outra skill (anvil-poteto, anvil-architect, anvil-arena), ou para consultar o vocabulário compartilhado de design: profundidade de interface, seam, alavanca, carga do leitor, disciplina de fronteira."
---

# Princípios

Vocabulário compartilhado de engenharia. Cada princípio diz **quando se aplica**
e **o que ele muda** — não é filosofia, é gatilho.

**Carregue o arquivo inteiro do princípio que você for aplicar.** Citar sem ter
lido não vale: a citação tem que rastrear até uma escolha concreta que a regra
do princípio dirigiu.

Chamado por `anvil-poteto` (todos), `anvil-architect` e `anvil-arena`.


## Core

- **[Laziness Protocol](references/laziness-protocol.md)** — Apply when refactoring, evaluating diff size, or tempted to add abstractions, layers, or signal threading. Bias toward deletion and the smallest change that solves the problem.
- **[Foundational Thinking](references/foundational-thinking.md)** — Apply before writing logic: choosing core types and data structures, sequencing scaffold-vs-feature work, asking what concurrent actors share. Get the data structures right so downstream code becomes obvious.
- **[Redesign From First Principles](references/redesign-from-first-principles.md)** — Apply when integrating a new requirement into an existing design. Redesign as if the requirement had been a foundational assumption from day one, instead of bolting it on.
- **[Subtract Before You Add](references/subtract-before-you-add.md)** — Apply when sequencing an addition, refactor, or rewrite. Remove dead weight, redundant validators, and stub references first, then build on the simpler base.
- **[Minimize Reader Load](references/minimize-reader-load.md)** — Apply when reviewing or shaping code that's hard to trace. Count layers between question and answer, and hidden state in the reader's head; collapse one-caller wrappers and shrink mutable scope.
- **[Outcome-Oriented Execution](references/outcome-oriented-execution.md)** — Apply during planned rewrites and migrations with explicit phase boundaries. Converge on the target architecture; don't preserve smooth intermediate states with throwaway compatibility code.
- **[Experience First](references/experience-first.md)** — Apply when product, UX, or feature-scope tradeoffs come up. Choose user delight over implementation convenience; ship fewer polished features over more rough ones.
- **[Exhaust the Design Space](references/exhaust-the-design-space.md)** — Apply when facing a novel UI interaction or architectural decision with no precedent in the codebase. Build 2-3 competing prototypes and compare side by side before committing.
- **[Build the Lever](references/build-the-lever.md)** — Apply to any non-trivial work, not just bulk work: edits, migrations, analyses, checks. Build the tool that does it or proves it (codemod, script, generator, or a skill your subagents follow) instead of working by hand. The tool is the artifact a reviewer can rerun.

## Arquitetura

- **[Model the Domain](references/model-the-domain.md)** — Apply when writing stateful logic, or when code branches a lot or repeats a shape assumption across files. Encode the domain in a structure instead of scattered conditionals.
- **[Boundary Discipline](references/boundary-discipline.md)** — Apply when wiring validation, error handling, or framework adapters. Concentrate guards at system boundaries (CLI, config, network, external APIs); trust internal types and keep business logic in pure functions.
- **[Type System Discipline](references/type-system-discipline.md)** — Apply when designing types, reviewing a function signature, or writing code in any statically-typed language. Make illegal states unrepresentable, brand semantic primitives, parse external data at boundaries, refuse to lie to the compiler, exhaust variants, derive from authoritative schemas.
- **[Separate Before Serializing Shared State](references/separate-before-serializing-shared-state.md)** — Apply when concurrent actors might write to the same file, branch, key, or state object. Eliminate the sharing first; serialize structurally only when one shared writer is a real invariant.
- **[Make Operations Idempotent](references/make-operations-idempotent.md)** — Apply when designing commands, lifecycle steps, or processing loops that run amid crashes, restarts, and retries. Converge to the same end state regardless of partial prior runs.
- **[Migrate Callers Then Delete Legacy APIs](references/migrate-callers-then-delete-legacy-apis.md)** — Apply when introducing a new internal API while old callers still exist. Migrate callers and delete the old API in the same wave instead of preserving compatibility layers.

## Verificação

- **[Prove It Works](references/prove-it-works.md)** — Apply after completing a task, before declaring done. Verify against the real artifact (run the feature, read the actual value, inspect the diff), not a proxy, self-report, or 'it compiles.'
- **[Sequence work into verifiable units](references/sequence-verifiable-units.md)** — Apply to multi-step work (sweeps, migrations, runs of similar edits) and to how you stack commits and PRs. Break work into small units that each end in a verifiable state, check each before the next, and order delivery so the sequence proves itself to a reviewer.
- **[Fix Root Causes](references/fix-root-causes.md)** — Apply when debugging. Trace each symptom to its root cause and fix it there; reproduce first, ask why until you reach it, resist nil-check guards that silence crashes.

## Delegação

- **[Never Block on the Human](references/never-block-on-the-human.md)** — Apply when tempted to ask 'should I do X?' on reversible work. Proceed, present the result, let the human course-correct after the fact; reserve confirmation for irreversible actions.
- **[Guard the Context Window](references/guard-the-context-window.md)** — Apply when context is filling up: large outputs, long files, repeated reads, fan-out planning. Route bulk to subagents; keep summaries in the main thread, not raw payloads.

## Meta

- **[Encode Lessons in Structure](references/encode-lessons-in-structure.md)** — Apply when you catch yourself writing the same instruction a second time, or notice a recurring correction. Encode the rule as a lint, metadata flag, runtime check, or script instead of more text.
