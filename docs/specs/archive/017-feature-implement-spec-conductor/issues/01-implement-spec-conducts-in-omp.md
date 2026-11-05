# 01: A `implement-spec` conduz a spec no omp, com review único e rodada 2

**What to build:** No omp, `/skill:anvil-implement-spec` leva uma spec do anvil ao branch dela: um implementer novo por ticket do frontier, isolado quando a isolação do omp está no modo branch e em série quando não está, todos chamando a `anvil-tdd`; os tickets fecham com `Status: resolved`; a `anvil-code-review` roda uma vez sobre o diff da spec inteira, com fixed point no ponto em que o branch saiu do branch base; um implementer novo corrige tudo; uma rodada 2 mede só o diff da correção, e P1 aberto nela para a execução com o P1 no relatório. Nenhum ticket ganha linha `Review:`. A decisão fica num ADR novo, que revê em parte os ADRs 0010, 0011, 0012, 0014 e 0020, cada um com ponteiro no cabeçalho. O perfil de verificação e o template dele descrevem o review único da spec, com o review por ticket só para o `anvil-implement` avulso. A regra `verification-profile` passa a constar no manifesto e no catálogo para a `implement-spec`, com o delta restrito à rodada 2. A rule de harness da camada omp mapeia o worktree por implementer para `isolated: true` e o merger para a integração do omp no modo branch; o manual `anvil-omp` descreve a skill como o condutor. Ver a spec, "O condutor", "No omp" e "Documentação e decisão".

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] No omp, sobre uma spec de três tickets (dois independentes, um que depende dos dois), a skill deixa os três `resolved` no branch da spec, com os dois independentes isolados quando a isolação está no modo branch.
- [x] O review roda uma vez sobre o diff da spec inteira, e nenhum ticket ganha linha `Review:`.
- [x] Com um P1 plantado que a correção não resolve, a execução termina com o P1 da rodada 2 no relatório e não marca a spec como pronta.
- [x] Sem a isolação no modo branch, os implementers rodam um por vez na árvore da spec.
- [x] O ADR novo existe, aceito, e os cinco ADRs revistos apontam para ele; `docs/index.md` o lista.
- [x] `docs/agents/verification.md` e o template do `anvil-docs` descrevem o review único da spec e o review por ticket do `anvil-implement` avulso.
- [x] O delta da `implement-spec` contra o pin fica restrito à rodada 2, declarado como `verification-profile` no manifesto e no catálogo.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Prova no omp real, `workspace/93-implement-spec/out-A2` e `out-B3`, depois de `4b3f510`: três itens com `isolated: true` e integração pelo omp (`omp/task/*`); um review sobre o diff da spec; nenhuma `Review:` em ticket; o P1 plantado para a execução na rodada 2 sem fechar ticket; sem isolação, um implementer por vez. A primeira prova (`out-A`, `out-B`, `out-B2`) reprovou três critérios: o condutor usava o `anvil-implementer` e não isolava, e a rodada 2 pulava quando a correção não mudava nada. Corrigido em `4b3f510` e `311a85f`.
- Review da spec · rodada 1 · P1 (Standards, reclassificado pelo condutor): o gate da spec, prometido pelo ADR-0023 e pelo perfil, não rodava fora do piloto — quem seguisse a skill fecharia tickets sem gate. Corrigido em `6049def`.
- Review da spec · rodada 2 · P1 (Spec): o gate do passo 7 valia também no bench, onde o perfil diz que ele não se aplica — o bench pararia por uma suíte que não é a prova dele. Corrigido em `cfcee20`, apontando o passo 7 para o perfil.
- Achado fora do escopo · P2: no Claude Code, sem a integração do omp, o merge do passo 4 e do passo 5 da `implement-spec` é bloqueado pela guarda de merge enquanto a spec está aberta; a integração prevista pela guarda é `git cherry-pick`. Esta execução integrou por cherry-pick. Quem conduzir no Claude Code esbarra na guarda até alguém traduzir o merge da skill para cherry-pick na rule de harness desse harness.
