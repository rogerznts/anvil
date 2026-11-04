# 08: O anvil deixa de ter o bench

**What to build:** Decisão do operador: o `anvil-bench` sai do anvil nesta atualização, com tudo o que só existe por ele. As provas da spec 017 mostraram que a construção do bench depende de o modelo copiar à mão a saída do checker — a `out-8` gravou um `PASS` sem `--reverify` — e o operador prefere tirar o modo a mantê-lo. Saem a skill `anvil-bench` inteira (`SKILL.md`, `GATE.md`, `CHECKLIST.md` e o `unlazy/` vendorizado, com o `gate-check.mjs`), o `anvil-stack-payload/bench/` inteiro (starter, `infra.sh`, `deploy.sh`, `env.sh`, invariantes), o modo bench do `anvil-auto` e do `anvil-omp` (o `--bench`, a entrevista, o ledger, o `--reverify` como `PASS`), o `--infra` do `proof.sh`, e toda citação viva ao bench nas skills, nos templates, nas regras, no catálogo e nos documentos de arquitetura. O piloto automático continua, só pelo grill. Os ADRs que decidiram o bench ficam como história; um ADR novo registra a remoção e o que ela revê. A `anvil-benchmark-checklist` não é o bench e fica.

**Blocked by:** None (can start immediately)

**Status:** resolved
**Review:** round=1; sha=006c27b; scope=full; verdict=fail; p1=open
**Review:** round=2; sha=351962e; scope=diff:006c27b..351962e; verdict=pass; p1=none

- [x] `anvil/.claude/skills/anvil-bench/` e `anvil/.claude/skills/anvil-stack-payload/bench/` não existem; `anvil-skills.yaml`, o `vendor-sync.sh` e o `anvil.lock` não citam o `unlazy` nem o bench.
- [x] O `anvil-auto` e o `anvil-omp` não têm modo bench: nenhum `--bench`, nenhuma seção "No bench", e o piloto só entra pelo grill.
- [x] Nenhum arquivo vivo — skills, templates, `.claude/rules/`, scripts de `anvil-sync`, README, `docs/architecture/overview.md`, `docs/project/plan.md`, `docs/agents/` — cita o `anvil-bench`, o `GATE.md` dele, o `gate-check.mjs` ou o `stack-payload/bench`; ADRs antigos e specs arquivadas ficam como estão.
- [x] Um ADR novo registra a remoção, aponta o que ela revê (ADR-0003, 0006, 0014, 0021, 0023) e é citado no índice dos ADRs.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0, e o bloco `ANVIL:DIRECTIVES` do `CLAUDE.md` raiz continua igual ao `claude_boot.md`.

## Comments

- Implementado em `4de0494` (skill e bench do payload), `9860b7f` (`--infra` do `proof.sh`), `e896998` (README, arquitetura, plano) e `006c27b` (ADR-0024). Saiu também o submodule `references/unlazy`, por decisão do operador. `verify: limpo`; o bloco de diretivas é igual ao `claude_boot.md`.
- Review round=1 · P1 (Spec): o `docs/index.md` listava o `discovery/bench-autonomo.md` como proposta, sem dizer que o modo saiu — quem segue o índice lê como vivo um modo removido. O documento é registro histórico e fica; o índice passa a marcá-lo como histórico, pelo ADR-0024.
- Review round=1 · P2 (Spec): a busca por `--infra` e a comparação das diretivas não foram concluídas pelo eixo. Rodadas pela sessão principal: `--infra` só aparece em ADRs e no histórico do git; o bloco de diretivas é igual.
- Review round=1 · P3 (Standards): o cabeçalho do ADR-0024 truncava "a única" sem o substantivo — corrigido. P3: a linha do `docs/index.md` sobre o ADR-0006 ainda diz "seis capacidades"; é o resumo da decisão de então, marcado "revisto em parte pelo adr-0024", e fica.
- Review round=2 · o P1 do índice e o P3 do ADR-0024 fecharam, sem regressão. P2 (Spec): o eixo não achou no `proof.sh` o padrão `claude-sonnet-5-5` que o parágrafo novo do `.claude/rules/project.md` cita — o padrão mora nos scripts de prova de `workspace/`, fora do git, como o próprio parágrafo diz; vale como nota.
