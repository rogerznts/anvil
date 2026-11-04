# ADR-0023 — A `implement-spec` conduz a spec, com um review só no fim

- Status: aceito
- Data: 2026-11-04
- Origem: [spec 017](../../specs/017-feature-implement-spec-conductor/spec.md), a `implement-spec` conduz a spec e substitui o `anvil-run`
- Revê em parte o [ADR-0010](./adr-0010-verificacao-tem-criterio-de-parada.md): o orçamento de duas rodadas passa a ser por spec no fluxo da spec
- Revê em parte o [ADR-0011](./adr-0011-omp-como-harness-com-camada-propria.md): o condutor do omp passa a ser a `anvil-implement-spec`
- Revê em parte o [ADR-0012](./adr-0012-frontier-em-paralelo-com-isolacao-do-omp.md): o paralelo vem da `anvil-implement-spec` com a isolação do omp, sem pedido
- Revê em parte o [ADR-0014](./adr-0014-piloto-automatico-fecha-sem-humano.md): o despacho e o `PASS` do piloto automático
- Revê em parte o [ADR-0020](./adr-0020-gate-por-ticket-no-commit-que-fecha.md): o gate deixa de ser por ticket no fluxo da spec

## Contexto

O anvil tinha dois jeitos de implementar uma spec, e nenhum era o mesmo nos três
harnesses. No omp, o `anvil-run` despachava um `anvil-implementer` por ticket, e
cada implementer fazia o próprio review em dois eixos, gravava a linha `Review:`
no ticket e rodava o gate. No Claude Code e no Codex, o operador abria uma sessão
de `/anvil-implement` por ticket, à mão.

O custo estava no lugar errado. Medido nas sessões do omp do operador, de 2026-09
a 2026-11, sobre 455 tickets: o implementer gastou perto de 89% dos tokens de uma
spec, com mediana de 114 turnos por ticket e o contexto crescendo de 26 mil para
268 mil tokens. Os eixos do review somaram mais 8%, uma rodada por ticket. Uma spec
de dez tickets pagava dez reviews, quando a pergunta era se a spec inteira estava
certa.

O condutor também era a parte mais pesada do toolkit para manter: o `anvil-run`, o
laço do `anvil-auto` e o `frontier.sh` carregavam retomada de despacho, pulados,
travados e leitura de isolação, tudo para servir o review por ticket. O upstream
que o anvil segue já tinha resolvido o mesmo problema com a `implement-spec`: um
implementer novo por ticket, cada um no próprio worktree, tudo junto num branch de
integração e um review só no fim.

## Decisão

**A `anvil-implement-spec`, vendorizada do mattpocock, conduz a spec nos três
harnesses.** Ela monta o frontier pelo grafo de bloqueio, despacha um implementer
novo por ticket, cada um chamando a `anvil-tdd`, e junta o trabalho no branch de
integração, que no anvil é o branch da spec, `{tipo}/{NNN}-{nome}`. Cada ticket
fecha com `Status: resolved`, como o perfil de tracker manda.

**O review é um só, da spec inteira.** Com todos os tickets prontos, a
`anvil-code-review` roda uma vez sobre o diff da spec, com o fixed point no ponto
em que o branch da spec saiu do branch base. Um implementer novo corrige tudo o
que ela levantou. Uma rodada 2 mede só o diff dessa correção, e P1 aberto nela
para a execução e vai para quem conduz, como o critério de parada do ADR-0010 — a
verificação tem critério de parada, e ele é ausência de P1 — manda. Nenhuma linha
`Review:` é gravada: o que vale é o resultado da execução e o gate.

**O delta no texto vendorizado é a rodada 2, pela regra `verification-profile`.**
A regra passa a valer para a `anvil-implement-spec` no menor delta possível: um
parágrafo no passo do review, com o fixed point das duas rodadas, a rodada 2 e a
parada por P1. O frontier, os worktrees e o merge ficam como o upstream escreveu.

**No omp, a tradução é da rule de harness da camada.** O worktree e o branch por
implementer são o `task` com `isolated: true`; o "merger subagent" é a integração
do omp no modo branch, o cherry-pick dos commits de cada implementer no branch da
spec. Sem a isolação no modo branch, os implementers rodam em série, um por vez,
na árvore da spec. O conflito de cherry-pick não tem tratamento próprio: o ticket
volta ao frontier e é despachado de novo, como no ADR-0012 — o frontier em
paralelo com a isolação do omp.

**O piloto automático e o bench usam a mesma skill.** O `PASS` passa a ser todo
ticket `resolved` e, fora do bench, o comando de verificação saindo `0`; a
condição da linha `Review:` sai. A spec para quando a execução termina com P1 na
rodada 2 ou com ticket que não fechou, e a pesquisa antes de travar vale para a
spec: com evidência nova, uma rodada a mais, uma vez por spec. No bench, o gate
continua sendo o `--reverify` do ledger.

**O gate, no fluxo da spec, roda uma vez sobre o branch da spec**, depois da
correção do review e antes de os tickets fecharem. O ticket avulso continua com o
gate no commit que o fecha.

**O `anvil-implement` não muda.** O ticket avulso continua com review por ticket,
linha `Review:` e a regra `verification-profile` dele.

**Saem o `anvil-run`, o `frontier.sh` dele e o agente `anvil-implementer`.** A
regra do implementer que proibia sub-agente que escreve sai com ele: o risco que
ela cobria, dois agentes na mesma árvore, a `implement-spec` resolve com um
worktree por implementer, e no omp sem isolação, com a série.

## O que cada ADR revisto perde

- **ADR-0010.** O orçamento de duas rodadas, no fluxo da spec, passa a ser por
  spec: rodada 1 no fim, rodada 2 sobre a correção. A persistência da rodada em
  `Review:` fica só no ticket avulso.
- **ADR-0011.** O condutor do omp deixa de ser o `anvil-run` com um
  `anvil-implementer` por ticket e passa a ser a `anvil-implement-spec`, que não
  é da camada: vem do payload, e a camada só a traduz.
- **ADR-0012.** O paralelo deixa de ser o `--parallel N` do `anvil-run`, sob
  pedido. Vem da `anvil-implement-spec`, que despacha o frontier inteiro, e só
  corre em paralelo com a isolação no modo branch.
- **ADR-0014.** O piloto deixa de ter laço próprio de despacho: somem a retomada
  por ticket, os pulados e os travados por `Review:`, e o `PASS` não lê mais a
  linha. A terceira rodada aberta por pesquisa passa a ser uma por spec.
- **ADR-0020.** No fluxo da spec, o gate deixa de rodar no commit que fecha cada
  ticket e roda uma vez, sobre o branch da spec. No ticket avulso, nada muda.

## Alternativas descartadas

- **Manter o `anvil-run` com review por ticket.** É o que custava 89% dos tokens
  no implementer e um review por ticket, e só existia no omp.
- **Review por ticket dentro da `implement-spec`.** Recuperaria a âncora por
  ticket e devolveria o custo que a troca corta, num delta grande sobre o texto
  vendorizado.
- **Gravar o veredito do review em disco.** Decisão do operador: o gate e o
  relatório da execução bastam, e uma linha que ninguém lê para decidir é
  registro morto.
- **Resolver o conflito de cherry-pick do omp automaticamente.** Continua fora,
  como no ADR-0012: o ticket que não entrou roda de novo sobre o que entrou.

## Consequências

**A favor.** Um condutor só nos três harnesses. O review se paga uma vez por spec,
e cada ticket nasce num contexto novo, sem o peso do anterior. Os tickets
independentes rodam ao mesmo tempo no omp com a isolação no modo branch, sem
pedido. O `sha` trocado pelo cherry-pick, que o ADR-0012 registrava na linha
`Review:`, deixa de importar: não há linha.

**Contra.** O vermelho do gate da spec volta a ser uma bissecção entre tickets,
que o ADR-0020 evitava; é o custo aceito de um gate e um review por spec. O
review da spec lê um diff maior de uma vez, e o que a rodada 1 não vir a rodada 2
não procura, porque mede só a correção. Sem linha
`Review:`, o histórico do review não fica no ticket: depois da execução, o que
resta dele é o relatório e os commits da correção.
