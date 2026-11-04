# 08: O anvil deixa de ter o bench

**What to build:** Decisão do operador: o `anvil-bench` sai do anvil nesta atualização, com tudo o que só existe por ele. As provas da spec 017 mostraram que a construção do bench depende de o modelo copiar à mão a saída do checker — a `out-8` gravou um `PASS` sem `--reverify` — e o operador prefere tirar o modo a mantê-lo. Saem a skill `anvil-bench` inteira (`SKILL.md`, `GATE.md`, `CHECKLIST.md` e o `unlazy/` vendorizado, com o `gate-check.mjs`), o `anvil-stack-payload/bench/` inteiro (starter, `infra.sh`, `deploy.sh`, `env.sh`, invariantes), o modo bench do `anvil-auto` e do `anvil-omp` (o `--bench`, a entrevista, o ledger, o `--reverify` como `PASS`), o `--infra` do `proof.sh`, e toda citação viva ao bench nas skills, nos templates, nas regras, no catálogo e nos documentos de arquitetura. O piloto automático continua, só pelo grill. Os ADRs que decidiram o bench ficam como história; um ADR novo registra a remoção e o que ela revê. A `anvil-benchmark-checklist` não é o bench e fica.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] `anvil/.claude/skills/anvil-bench/` e `anvil/.claude/skills/anvil-stack-payload/bench/` não existem; `anvil-skills.yaml`, o `vendor-sync.sh` e o `anvil.lock` não citam o `unlazy` nem o bench.
- [ ] O `anvil-auto` e o `anvil-omp` não têm modo bench: nenhum `--bench`, nenhuma seção "No bench", e o piloto só entra pelo grill.
- [ ] Nenhum arquivo vivo — skills, templates, `.claude/rules/`, scripts de `anvil-sync`, README, `docs/architecture/overview.md`, `docs/project/plan.md`, `docs/agents/` — cita o `anvil-bench`, o `GATE.md` dele, o `gate-check.mjs` ou o `stack-payload/bench`; ADRs antigos e specs arquivadas ficam como estão.
- [ ] Um ADR novo registra a remoção, aponta o que ela revê (ADR-0003, 0006, 0014, 0021, 0023) e é citado no índice dos ADRs.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0, e o bloco `ANVIL:DIRECTIVES` do `CLAUDE.md` raiz continua igual ao `claude_boot.md`.

## Comments
