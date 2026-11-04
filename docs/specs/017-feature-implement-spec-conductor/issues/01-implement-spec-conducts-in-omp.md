# 01: A `implement-spec` conduz a spec no omp, com review único e rodada 2

**What to build:** No omp, `/skill:anvil-implement-spec` leva uma spec do anvil ao branch dela: um implementer novo por ticket do frontier, isolado quando a isolação do omp está no modo branch e em série quando não está, todos chamando a `anvil-tdd`; os tickets fecham com `Status: resolved`; a `anvil-code-review` roda uma vez sobre o diff da spec inteira, com fixed point no ponto em que o branch saiu do branch base; um implementer novo corrige tudo; uma rodada 2 mede só o diff da correção, e P1 aberto nela para a execução com o P1 no relatório. Nenhum ticket ganha linha `Review:`. A decisão fica num ADR novo, que revê em parte os ADRs 0010, 0011, 0012, 0014 e 0020, cada um com ponteiro no cabeçalho. O perfil de verificação e o template dele descrevem o review único da spec, com o review por ticket só para o `anvil-implement` avulso. A regra `verification-profile` passa a constar no manifesto e no catálogo para a `implement-spec`, com o delta restrito à rodada 2. A rule de harness da camada omp mapeia o worktree por implementer para `isolated: true` e o merger para a integração do omp no modo branch; o manual `anvil-omp` descreve a skill como o condutor. Ver a spec, "O condutor", "No omp" e "Documentação e decisão".

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] No omp, sobre uma spec de três tickets (dois independentes, um que depende dos dois), a skill deixa os três `resolved` no branch da spec, com os dois independentes isolados quando a isolação está no modo branch.
- [ ] O review roda uma vez sobre o diff da spec inteira, e nenhum ticket ganha linha `Review:`.
- [ ] Com um P1 plantado que a correção não resolve, a execução termina com o P1 da rodada 2 no relatório e não marca a spec como pronta.
- [ ] Sem a isolação no modo branch, os implementers rodam um por vez na árvore da spec.
- [ ] O ADR novo existe, aceito, e os cinco ADRs revistos apontam para ele; `docs/index.md` o lista.
- [ ] `docs/agents/verification.md` e o template do `anvil-docs` descrevem o review único da spec e o review por ticket do `anvil-implement` avulso.
- [ ] O delta da `implement-spec` contra o pin fica restrito à rodada 2, declarado como `verification-profile` no manifesto e no catálogo.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
