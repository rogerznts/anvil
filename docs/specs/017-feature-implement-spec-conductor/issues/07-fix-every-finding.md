# 07: A correção do review da spec cobre todo achado, e o veredito é dos eixos

**What to build:** Decisões do operador. (1) No fluxo da spec, quando a rodada 1 do review acha qualquer coisa — P1, P2 ou P3 —, um implementer novo corrige tudo e a rodada 2 mede o diff da correção, como o "Fix all issues" da `anvil-implement-spec` diz; só a rodada 1 sem achado nenhum dispensa a correção e a rodada 2. Hoje o perfil de verificação diz que P2 e P3 "registram e seguem", e nas provas dos tickets 05 e 06 o condutor pulou a correção quando a rodada 1 só tinha P2 e P3. (2) O veredito do review é dos eixos: o condutor não descarta nem reclassifica achado e não grava linha `Review:` — regra que o `anvil-implementer` tinha e que saiu com ele; na prova `out-7` do ticket 06, a sessão do bench descartou um P1 da rodada 2 e fechou a spec. (3) O `updated` do `gate.yaml` vem do relógio, `date -u`, rodado logo depois do `--reverify`; a prova `out-7` gravou um horário inventado. O passo 7 diz (1) e (2) por extenso; o perfil de verificação e o ADR-0023 registram (1) para o fluxo da spec, e o ticket avulso continua com a regra do ADR-0010; o `GATE.md` diz (3).

**Blocked by:** 01

**Status:** ready-for-agent

- [ ] O passo 7 da `anvil-implement-spec` diz que todo achado da rodada 1, P2 e P3 inclusive, vai ao implementer de correção, que só a rodada sem achado dispensa a correção e a rodada 2, e que o condutor não descarta nem reclassifica achado; o catálogo reproduz o delta.
- [ ] `docs/agents/verification.md` e o template do `anvil-docs` dizem a regra da correção para o fluxo da spec, sem mudar a do ticket avulso; o ADR-0023 a registra.
- [ ] O `GATE.md` manda tirar o `updated` de um `date -u` rodado logo depois do `--reverify`.
- [ ] Num projeto do bench no omp real, com rodada 1 com achado, a correção sai de um implementer novo, a rodada 2 mede o diff dela, nenhum achado de eixo é descartado pelo condutor, nenhuma linha `Review:` é gravada e o `updated` do `gate.yaml` é posterior ao fim do `--reverify`.
- [ ] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.
