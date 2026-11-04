# 017 — A `implement-spec` conduz a spec, com um review só no fim, e substitui o `anvil-run`

**Status:** ready-for-agent

O anvil passa a implementar uma spec inteira pela `anvil-implement-spec`, vendorizada
do mattpocock, nos três harnesses. Ela substitui o condutor autoral `anvil-run`, da
camada omp, e o laço de despacho por ticket do piloto automático, o `anvil-auto`.
Com ela saem o agente `anvil-implementer` e o script `frontier.sh`. A verificação
deixa de ser por ticket e passa a ser um review só, da spec inteira, no fim.

## Problem Statement

Hoje o anvil tem dois jeitos de implementar uma spec, e nenhum é o mesmo nos três
harnesses. No omp, o `anvil-run` despacha um `anvil-implementer` por ticket, em
série, e cada implementer faz o próprio review em dois eixos, grava a linha
`Review:` no ticket e roda o gate. No Claude Code e no Codex, o operador abre uma
sessão de `/anvil-implement` por ticket, à mão.

O custo é alto e fica no lugar errado. Medido nas sessões do omp, o implementer
gasta perto de 89% dos tokens de uma spec: a mediana é de 114 turnos por ticket,
com o contexto crescendo de 26 mil para 268 mil tokens. Os eixos do review somam
mais 8%, uma rodada por ticket. Um ticket de uma spec de dez paga dez reviews,
quando o que se quer saber é se a spec inteira está certa.

O condutor também é a parte mais pesada do toolkit para manter. O `anvil-run`, o
laço do `anvil-auto` e o `frontier.sh` carregam retomada de despacho, pulados,
travados e leitura de isolação, tudo para servir o review por ticket. O upstream
que o anvil segue já resolveu o mesmo problema de outro jeito: a `implement-spec`
despacha um implementer novo por ticket, cada um no próprio worktree, junta tudo
num branch de integração e revisa uma vez só.

## Solution

A `anvil-implement-spec` passa a ser o condutor da spec, em qualquer harness:

1. Lê a spec e os tickets, monta o grafo de bloqueio e despacha um implementer
   novo por ticket do frontier, cada um no próprio worktree e branch, que chama a
   `anvil-tdd` para construir o ticket.
2. Junta o trabalho de cada implementer no branch de integração, que no anvil é o
   próprio branch da spec.
3. Com todos os tickets prontos, chama a `anvil-code-review` uma vez só, sobre o
   diff da spec inteira. Um implementer novo corrige tudo que o review levantou.
4. Uma rodada 2 do review mede só o diff dessa correção. P1 aberto na rodada 2
   para a spec, como o critério de parada do anvil manda.
5. Cada ticket é fechado com `Status: resolved`, como o perfil de tracker manda.

O piloto automático usa a mesma skill no lugar do laço próprio, e fecha a spec com
`PASS` quando todos os tickets estão `resolved` e o comando de verificação do
projeto sai `0`. O review não deixa registro em disco: o que vale é o resultado
da execução e o gate.

O `anvil-bench` também passa a construir pela `implement-spec`, com o review único
e o gate do ledger no fim. O `anvil-implement` continua existindo para o ticket
avulso, com o review por ticket de hoje.

## User Stories

1. Como operador no omp, quero implementar uma spec inteira com uma chamada só, para não conduzir ticket a ticket.
2. Como operador no Claude Code, quero o mesmo condutor que no omp, para não abrir uma sessão por ticket.
3. Como operador no Codex, quero o mesmo condutor, para os três harnesses seguirem um fluxo só.
4. Como operador, quero que cada ticket seja construído por um implementer de contexto novo, para que o contexto de um ticket não pese no seguinte.
5. Como operador, quero que tickets independentes rodem ao mesmo tempo, cada um no próprio worktree, para a spec terminar mais cedo sem dois agentes na mesma árvore.
6. Como operador, quero que o trabalho de cada implementer chegue ao branch da spec, para o branch da spec ser o branch de integração.
7. Como operador, quero um review só, sobre a spec inteira, para pagar a revisão uma vez e não uma por ticket.
8. Como operador, quero que um implementer novo corrija o que o review levantou, para a correção não carregar o contexto da construção.
9. Como operador, quero uma rodada 2 só sobre o diff da correção, para saber se a correção quebrou outra coisa sem revisar a spec de novo.
10. Como operador, quero que um P1 aberto na rodada 2 pare a spec, para não fechar trabalho que a revisão reprovou duas vezes.
11. Como operador, quero que cada ticket termine com `Status: resolved`, para a guarda de merge liberar a spec como hoje.
12. Como operador do piloto automático, quero que ele implemente cada spec do roteiro pela mesma skill, para o piloto e o fluxo manual não divergirem.
13. Como operador do piloto, quero que o `PASS` seja tickets `resolved` e o comando de verificação verde, para o fechamento não depender de um registro que não existe mais.
14. Como operador do piloto, quero que a spec pare com o motivo quando a rodada 2 ainda tiver P1, para decidir eu mesmo a terceira rodada.
15. Como operador do piloto, quero que a pesquisa antes de travar continue valendo, agora sobre a spec, para o piloto ainda poder abrir uma rodada a mais com evidência nova.
16. Como quem pede uma ferramenta ao `anvil-bench`, quero que o bench construa pela mesma skill, para a entrega sair com o review único e o gate do ledger.
17. Como quem pede uma ferramenta ao bench, quero que o veredito do gate continue saindo do `--reverify` do ledger, para o bench não confiar no que o agente disse ter feito.
18. Como operador, quero que o `anvil-implement` continue para o ticket avulso, para consertar um ticket só sem rodar a spec inteira.
19. Como mantenedor do anvil, quero que o `anvil-run`, o `anvil-implementer` e o `frontier.sh` saiam, para não manter um condutor que ninguém usa.
20. Como mantenedor, quero que o `anvil-plan` termine indicando a `implement-spec`, para o fim do planejamento apontar para o condutor que existe.
21. Como mantenedor, quero que a camada omp traduza worktree e merge da `implement-spec` para a isolação do omp, para a skill vendorizada rodar no omp sem mudar o texto dela.
22. Como mantenedor, quero que o perfil de verificação descreva o review único por spec, para nenhuma skill ler uma régua que não vale mais.
23. Como mantenedor, quero um ADR que registre a troca e reveja os ADRs atingidos, para ninguém restaurar o review por ticket achando que foi esquecido.
24. Como mantenedor, quero que a instalação de usuário apague o `anvil-run`, o `anvil-implementer` e o `frontier.sh` no próximo update, para não sobrar condutor velho instalado.
25. Como mantenedor, quero que o `vendor-sync.sh verify` continue passando, para a mudança não quebrar a verificação de antes do commit.
26. Como mantenedor, quero o README, o overview, o glossário e o manual da camada omp falando do condutor novo, para a documentação não mandar ninguém para uma skill que não existe.

## Implementation Decisions

### O condutor

- A `anvil-implement-spec` entra no fluxo como está no upstream: frontier por grafo
  de bloqueio, implementer novo por ticket em worktree próprio, merge no branch de
  integração, review uma vez no fim, correção num implementer novo. O branch de
  integração do anvil é o branch da spec, `{tipo}/{NNN}-{nome}`.
- A regra `verification-profile` passa a valer também para a `implement-spec`, no
  menor delta possível: depois da correção, uma rodada 2 do `anvil-code-review`
  sobre o diff da correção; P1 aberto nela para a execução e reporta o P1. Nenhuma
  linha `Review:` é gravada. O catálogo e o manifesto registram a regra nessa
  skill.
- O review da `anvil-code-review`, chamado pela `implement-spec`, usa como fixed
  point o ponto em que o branch da spec saiu do branch base, e o escopo é o diff da
  spec inteira.
- O `anvil-implement` e a regra `verification-profile` dele não mudam: o ticket
  avulso continua com review por ticket e linha `Review:`.

### No omp

- A rule de harness da camada omp ganha o mapeamento da `implement-spec`: "um
  worktree e um branch por implementer" é o `task` com `isolated: true`; o "merger
  subagent" é a integração do omp no modo branch, que faz o cherry-pick dos commits
  do implementer no branch da spec. Sem a isolação no modo branch, os implementers
  rodam em série, um por vez, na árvore da spec.
- O manual `anvil-omp` passa a descrever a `implement-spec` como o condutor, com
  esse mapeamento e a configuração de isolação que ele pede.

### O piloto automático

- A seção de despacho do `anvil-auto` passa a chamar a `implement-spec` sobre a
  spec, no branch dela, e não mais o laço do `frontier.sh` com o
  `anvil-implementer`. Somem a retomada do despacho por ticket, os pulados e os
  travados por `Review:`.
- O `PASS` passa a ser: todo ticket de `issues/` com `Status: resolved` e, fora do
  bench, o comando de verificação saindo `0` pelo `verification.sh`. A condição da
  linha `Review:` sai.
- A spec para quando a execução da `implement-spec` termina com P1 aberto na rodada
  2, ou com ticket que não fechou. A "Pesquisa antes de travar" passa a valer para
  a spec: com evidência nova de pesquisa, o piloto pode abrir uma rodada a mais da
  spec, uma vez por spec, registrada no relatório. A linha do piloto no
  `## Comments` do ticket sai do perfil de tracker.

### O bench

- A fase "Construir" do `anvil-bench` passa a ser `implement-spec` sobre a spec da
  entrada, seguida do gate que reexecuta o ledger. O teto de duas rodadas passa a
  ser o da spec: rodada 1 no fim, rodada 2 sobre a correção.
- O `GATE.md` troca as condições por ticket pelas da spec: `CONCERNS` quando a
  rodada 2 da spec ainda tem P1; `FAIL` quando o `--reverify` derruba um gate.

### O que sai

- A skill `anvil-run` e o `frontier.sh` dela; o agente `anvil-implementer`. A
  camada omp, o manifesto da camada e o `anvil.lock` deixam de listá-los, e o
  `reset-install.sh` apaga a cópia instalada no próximo update, como já faz com
  órfão do lock.
- As menções a eles no `roadmap.sh`, no `stage.sh` e no `anvil-plan` passam a
  apontar para a `implement-spec`, inclusive a linha `handoff` do `stage.sh`.
- A cauda de roteamento do `claude_boot.md` troca o `anvil-run` pela
  `anvil-implement-spec` e tira a exceção que só existia para ele.

### Documentação e decisão

- Um ADR novo registra a troca: o condutor é a `implement-spec`, o review é único
  por spec, o `PASS` não lê `Review:`. Ele revê em parte o ADR-0010 (o orçamento de
  duas rodadas passa a ser por spec), o ADR-0011 (o condutor do omp), o ADR-0012
  (o paralelo vem da `implement-spec` com a isolação do omp), o ADR-0014 (o
  despacho e o `PASS` do piloto) e o ADR-0020 (o gate deixa de ser por ticket no
  fluxo da spec). Cada um ganha uma linha de ponteiro no cabeçalho.
- O perfil `docs/agents/verification.md` e o template dele no `anvil-docs`
  descrevem o review único da spec, mantendo o review por ticket só para o
  `anvil-implement` avulso.
- README, overview, glossário e `docs/index.md` passam a falar do condutor novo.

## Testing Decisions

- Não há suíte. A verificação automática é
  `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify`, que precisa sair
  limpa, inclusive o `anvil.lock` sem o `anvil-run` e o `anvil-implementer`.
- O comportamento se prova num cenário real no omp, em `workspace/`, fora do git,
  pelo helper de prova (`proof.sh`), sobre uma spec de três tickets em que dois
  são independentes e um depende dos dois:
  - **Condutor:** `/skill:anvil-implement-spec` leva a spec ao branch dela. Os três
    tickets ficam `resolved`, os dois independentes rodam isolados, o review roda
    uma vez sobre a spec inteira, e nenhum ticket ganha linha `Review:`.
  - **Piloto:** o `anvil-auto` sobre um roteiro de uma entrada com a mesma spec
    fecha com `PASS`, sem ler `Review:`, faz o archive e o merge, e a guarda de
    merge libera.
  - **Parada:** com um P1 plantado que a correção não resolve, a execução termina
    com o P1 da rodada 2, e o piloto para a spec com o motivo.
- O que se observa é o que fica no disco e no git — tickets, branch, commits,
  relatório —, nunca a redação das skills.

## Out of Scope

- Mudar o texto vendorizado da `implement-spec` além da rodada 2 e do mapeamento
  de harness, que fica na rule da camada omp.
- Mudar o `anvil-implement` e o review por ticket dele.
- Gravar o veredito do review em disco: decisão do operador, o gate basta.
- Resolver conflito de cherry-pick do omp automaticamente: continua como o ADR-0012
  descreve.

## Further Notes

- A regra do `anvil-implementer` que proibia sub-agente que escreve sai com ele. O
  risco que ela cobria, dois agentes na mesma árvore, a `implement-spec` resolve
  com um worktree por implementer.
- A medição de custo citada no problema é das sessões do omp do operador, de
  2026-09 a 2026-11: 455 tickets, 12 bilhões de tokens no implementer.
