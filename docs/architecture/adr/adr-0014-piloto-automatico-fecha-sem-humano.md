# ADR-0014 — O piloto automático leva o roteiro ao fechamento sem humano

- Status: aceito
- Data: 2026-10-14
- Revê em parte o [ADR-0011](./adr-0011-omp-como-harness-com-camada-propria.md), só para quem dispara o piloto automático
- Revê em parte o [ADR-0010](./adr-0010-verificacao-tem-criterio-de-parada.md): a terceira rodada pode ser aberta pelo piloto, por evidência nova de pesquisa

## Contexto

O ADR-0011 pôs a automação no omp com duas peças que existem para ter pausa: a
`anvil-plan` só carrega etapa com o sim do operador, e a `anvil-run` para em
"todos resolvidos", deixando archive, PR e merge com o usuário. O `anvil-bench`
quer ir da entrevista ao app entregue, e um app quase nunca cabe numa spec: com
uma pausa por etapa e um grill por spec, quem pediu fica preso à conversa até o
fim.

## Decisão

**Uma skill nova da camada omp, `anvil-auto`, com trava de invocação, conduz sem
pausa humana depois de um único ponto de entrada.** Vale para qualquer projeto do
anvil, não só para o bench.

- **Entrada.** O operador participa só no começo: o `anvil-grill` num projeto
  comum, a entrevista no bench. O grill cobre o plano inteiro — specs, ordem,
  escopo e critério de pronto de cada uma — e o entendimento confirmado é o único
  sim. Dele sai o roteiro, a entrada de formato fixo que o piloto lê; o plano em
  prosa de `docs/project/` continua da pessoa.
- **Corrente.** Spec por spec, pelo frontier do roteiro — a entrada cujas
  dependências já fecharam: branch pelo `new-spec.sh`, `anvil-to-spec`,
  `anvil-to-tickets`, o laço de despacho da `anvil-run`, archive e merge, e só
  então a próxima. Sem grill entre elas. O piloto responde às pausas das skills de
  etapa e registra cada resposta no relatório.
- **Só `PASS` fecha.** No bench, o `PASS` é o `gate-check.mjs --reverify` rodado
  pelo supervisor. Fora dele, todos os tickets `resolved` com a última `Review:`
  em `verdict=pass; p1=none` e o comando de verificação das rules saindo `0`.
  Projeto sem comando de verificação declarado é recusado na largada.
- **Spec que não fecha sozinha fica aberta no seu branch**: `CONCERNS`, ticket
  travado em `round=2`, gate manual aberto ou fechamento que passa por PR — o
  piloto abre o PR e não faz merge. A corrente segue com as entradas que não
  dependem dela, direta nem indiretamente, cada uma num branch novo saído da
  `main`, e termina quando não sobra entrada desbloqueada.
- **Pesquisa antes de travar.** Na parada técnica — ticket travado em `round=2`,
  verificação que falha no `PASS`, implementer bloqueado por fato desconhecido,
  `FAIL` no teto do bench —, o piloto roda o `anvil-research` contra fontes
  primárias da web e grava o achado em `docs/specs/{id}/discovery/`. Se ele traz
  evidência nova — fonte citada que explica a falha e ainda não está no ticket —,
  o piloto abre **uma** rodada a mais e registra no ticket que a abriu e por qual
  arquivo; essa evidência é a escolha explícita que o ADR-0010 pede a um humano.
  Os sinais de laço de `docs/agents/verification.md` bloqueiam essa rodada mesmo
  com evidência. Parada por decisão — gate manual, PR, contradição com o roteiro —
  não pesquisa: vai direto para o relatório.
- **Saída.** Um relatório da corrente, com o que foi feito, o que foi decidido
  sem humano e a seção "o que ainda espera decisão", que vira a pauta da oferta de
  grill novo.

A `anvil-plan` e a `anvil-run` não mudam: o piloto reusa o `stage.sh`, o
`frontier.sh` e as skills de etapa, e só decide a ordem e responde às pausas. A
guarda de merge vale como sempre. Fora do omp, o fluxo segue manual; o bench no
Claude Code para no fim da construção, como antes.

## Alternativas descartadas

- **Modo `--auto` na `anvil-plan` e na `anvil-run`.** Põe um "a não ser que" em
  cada regra "nunca" das peças que existem para pausar, e uma flag esquecida faz o
  modo autônomo vazar para uma execução manual.
- **O bench conduzindo sozinho.** O bench é núcleo e roda no Claude Code; conduzir
  spec, tickets e implementer nele o amarra ao `task` do omp e copia a lógica dos
  condutores.
- **Uma spec por execução, com grill antes de cada uma.** Mais seguro contra
  decisão tomada cedo demais, mas devolve a pessoa à conversa a cada spec, que é o
  que o pedido quer tirar.
- **Branches empilhados para atravessar o PR.** Uma mudança pedida na revisão do
  primeiro PR obrigaria a refazer todos os de cima.
- **Formato fixo no plano de `docs/project/`.** Quebra o "ninguém escreve aqui" do
  `anvil-docs` e os planos existentes.

## Consequências

**A favor.** Um app de várias specs sai de um grill só. Cada fechamento continua
atrás do mesmo `PASS` e da mesma guarda, e uma correção no `frontier.sh` vale
para os dois fluxos.

**Contra.** As decisões das últimas specs são tomadas antes de existir o código
das primeiras; o piloto adapta sozinho o que o código contradisser, e só o
relatório mostra isso. Pode haver mais de uma spec aberta ao mesmo tempo, em
branches diferentes; com remoto, tudo o que depende de um PR espera o merge dele.
O termo **Condutor** continua significando parar em cada pausa; o piloto é peça à
parte.
