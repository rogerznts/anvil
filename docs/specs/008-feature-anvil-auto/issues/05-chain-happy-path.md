# 05: O piloto leva cada entrada do roteiro da spec ao merge local, com relatório

**Blocked by:** 04

**Status:** ready-for-agent

**What to build:** depois do roteiro confirmado, o piloto executa a corrente sem
pausa, num projeto que fecha sem PR. O laço segue a seção "Corrente" da spec,
sem os desvios de parada. Para cada `next` do `roadmap.sh`, o piloto roda o
`new-spec.sh` com o `Tipo:` e o nome da entrada, commita `Spec: NNN` na `main`,
avança o branch da spec até esse commit, roda `anvil-to-spec` e
`anvil-to-tickets` com as pausas respondidas por ele e o laço de despacho da
`anvil-run`, em série. Depois confere o `PASS` e fecha com `anvil-docs archive` e
merge local na `main`. A cada fronteira de spec, atualiza e commita
`docs/specs/report.md` na `main`. Quando o `next` vira `none`, termina oferecendo
um grill novo com a pauta de "o que ainda espera decisão".

- [ ] O `Spec: NNN` aparece na `main` antes de qualquer commit no branch da spec,
      e o branch da spec contém esse commit.
- [ ] Cada pausa de `anvil-to-spec` e `anvil-to-tickets` é respondida com a
      opção recomendada pela skill ou, sem recomendação, com a mais conservadora,
      e pergunta e resposta vão para o relatório.
- [ ] O laço de despacho é o da `anvil-run`: `frontier.sh`, um
      `anvil-implementer` por ticket, pulados no `--skip`, parada no `halt`. A
      `anvil-run` e os scripts dela não mudam.
- [ ] O `PASS` fora do bench exige todos os tickets `resolved`, a última
      `Review:` em `verdict=pass; p1=none` e o bloco de
      `## Comando de verificação` rodado pelo piloto saindo `0`, com a saída
      gravada no relatório.
- [ ] Com `PASS`, vem o archive no branch da spec, com commit, e depois o merge
      local na `main`, sob a guarda de merge, sem contorno.
- [ ] Um conflito de merge só no `docs/index.md` é resolvido gerando o índice de
      novo, e o merge é concluído.
- [ ] O `report.md` tem o conteúdo da seção "Relatório" da spec e é commitado na
      `main` a cada fronteira.
- [ ] A cauda de roteamento não dispara dentro de uma execução do `anvil-auto`:
      a linha entra na lista "A cauda não dispara" do bloco de diretivas do
      payload e na rule da camada omp que o espelha. O `anvil-auto` não entra na
      lista de skills com cauda.
- [ ] S2: a corrente de duas entradas, a segunda dependente da primeira, com um
      comando de verificação trivial, fecha as duas. A segunda nasce de um branch
      saído da `main` já com a primeira.
- [ ] `vendor-sync.sh verify` sai `0`.
