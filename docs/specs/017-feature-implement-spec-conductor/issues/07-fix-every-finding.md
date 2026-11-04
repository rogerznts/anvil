# 07: A correção do review da spec cobre todo achado, P2 e P3 inclusive

**What to build:** Decisão do operador: no fluxo da spec, quando a rodada 1 do review acha qualquer coisa — P1, P2 ou P3 —, um implementer novo corrige tudo e a rodada 2 mede o diff da correção, como o "Fix all issues" da `anvil-implement-spec` diz. Só a rodada 1 sem achado nenhum dispensa a correção e a rodada 2. Hoje o passo 7 manda corrigir tudo, mas o perfil de verificação diz que P2 e P3 "registram e seguem", e nas provas dos tickets 05 e 06 o condutor pulou a correção quando a rodada 1 só tinha P2 e P3. O passo 7 diz isso por extenso, o perfil de verificação e o ADR-0023 registram a regra para o fluxo da spec, e o ticket avulso continua com a regra do ADR-0010.

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] O passo 7 da `anvil-implement-spec` diz que todo achado da rodada 1, P2 e P3 inclusive, vai ao implementer de correção, e que só a rodada sem achado dispensa a correção e a rodada 2; o catálogo reproduz o delta.
- [ ] `docs/agents/verification.md` e o template do `anvil-docs` dizem a mesma regra para o fluxo da spec, sem mudar a do ticket avulso; o ADR-0023 a registra.
- [ ] Numa spec cuja rodada 1 acha só P2 ou P3, conduzida pela `implement-spec` no omp real, a correção sai de um implementer novo e a rodada 2 mede o diff dela.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
