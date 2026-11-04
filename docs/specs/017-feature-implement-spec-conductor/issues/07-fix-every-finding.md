# 07: A correção do review da spec cobre todo achado, e o veredito é dos eixos

**What to build:** Decisões do operador. (1) No fluxo da spec, quando a rodada 1 do review acha qualquer coisa — P1, P2 ou P3 —, um implementer novo corrige tudo e a rodada 2 mede o diff da correção, como o "Fix all issues" da `anvil-implement-spec` diz; só a rodada 1 sem achado nenhum dispensa a correção e a rodada 2. Hoje o perfil de verificação diz que P2 e P3 "registram e seguem", e nas provas dos tickets 05 e 06 o condutor pulou a correção quando a rodada 1 só tinha P2 e P3. (2) O veredito do review é dos eixos: o condutor não descarta nem reclassifica achado e não grava linha `Review:` — regra que o `anvil-implementer` tinha e que saiu com ele; na prova `out-7` do ticket 06, a sessão do bench descartou um P1 da rodada 2 e fechou a spec. (3) O `updated` do `gate.yaml` vem do relógio, `date -u`, rodado logo depois do `--reverify`; a prova `out-7` gravou um horário inventado. O passo 7 diz (1) e (2) por extenso; o perfil de verificação e o ADR-0023 registram (1) para o fluxo da spec, e o ticket avulso continua com a regra do ADR-0010; o `GATE.md` diz (3).

**Blocked by:** 01

**Status:** claimed
**Review:** round=1; sha=c26b9cf; scope=full; verdict=pass; p1=none

- [x] O passo 7 da `anvil-implement-spec` diz que todo achado da rodada 1, P2 e P3 inclusive, vai ao implementer de correção, que só a rodada sem achado dispensa a correção e a rodada 2, e que o condutor não descarta nem reclassifica achado; o catálogo reproduz o delta.
- [x] `docs/agents/verification.md` e o template do `anvil-docs` dizem a regra da correção para o fluxo da spec, sem mudar a do ticket avulso; o ADR-0023 a registra.
- [x] ~~O `GATE.md` manda tirar o `updated` de um `date -u` rodado logo depois do `--reverify`.~~ Superado: o `GATE.md` sai com o bench no ticket 08.
- [ ] O passo 7 dá ao condutor uma saída para o achado que ele julga errado: ele o devolve ao eixo que o levantou, com o motivo; o eixo mantém, e o achado vai à correção, ou retira, e o achado sai pela palavra do eixo. O condutor nunca o descarta sozinho. O catálogo reproduz o delta, e o perfil de verificação e o ADR-0023 dizem o mesmo.
- [ ] Numa spec com rodada 1 com achado, conduzida pela `implement-spec` no omp real com o `claude-sonnet-5-5`, fora do bench, a correção sai de um implementer novo, a rodada 2 mede o diff dela, nenhum achado é descartado pelo condutor sem a palavra do eixo e nenhuma linha `Review:` é gravada.
- [x] `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify` sai 0.

## Comments

- Review round=1 · P2 (Standards): a tabela de classes do perfil dizia "P2 registra e segue" sem escopo, contra o fluxo da spec — corrigido em `3297465`, que aponta para *Onde a revisão roda*.
- Review round=1 · P2 (Standards): a frase de parada do bench lia "para" como preposição — reescrita em `3297465`.
- Review round=1 · P3 (Standards): o corpo do ADR-0010 não cita a exceção do fluxo da spec; só o cabeçalho "Revisto em parte" aponta o ADR-0023.
- Prova `out-8`, sobre `c26b9cf`, critério 4 **falha**: a rodada 1 achou um P1 e dois P3; a correção saiu de um implementer novo (`6c5e163`) e a rodada 2 mediu `7032ddd..6c5e163`, sem linha `Review:` em ticket e com `updated` de `date -u` — mas o condutor descartou os dois P3 como "acceptable" e não rodou o `--reverify` (ver o ticket 06).
- Causa do descarte na `out-8`: os dois P3 eram falsos positivos — o eixo Spec chamou de "scope creep" o `gates.md` e o `decisions-log.md`, que o bench exige —, e "corrigir tudo" não tinha saída para achado errado: corrigir apagaria o ledger. O condutor acertou no mérito e desobedeceu a regra. Daí o critério da devolução ao eixo.
