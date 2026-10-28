# 016 — O grill pergunta pela ferramenta de pergunta do harness, em blocos de 10

**Status:** resolved

Extensão do `anvil-grilling`, skill vendorizada do mattpocock com pin, que o
`anvil-grill`, o `anvil-grill-me`, o `anvil-wayfinder` e o `anvil-bench` chamam.
A mudança entra como regra nova no catálogo fechado de adaptações, com ADR
próprio, no mesmo formato que o `verification-profile` usou para entrar junto do
`ADR-0010` — a verificação tem critério de parada.

## Problem Statement

Quando o operador roda um grill, cada rodada chega como um bloco de texto longo.
O `anvil-grilling` manda fazer, numa rodada só, todas as perguntas cuja resposta
não depende de outra ainda aberta, cada uma com título, corpo de vários parágrafos,
alternativas e a resposta recomendada. Com 20 dúvidas, o operador recebe um
paredão, precisa rolar a tela para achar as alternativas e responde em prosa livre,
citando o número de cada pergunta. Escolher é caro, e é fácil deixar uma pergunta
sem resposta.

Os três harnesses em que o anvil roda já têm uma ferramenta de pergunta
estruturada, com opções clicáveis: o `AskUserQuestion` no Claude Code, o `ask` no
omp e o `request_user_input` no Codex. O grill não a usa porque o upstream fixa o
formato de texto.

O grill também não diz quanto falta. O operador não sabe se está na pergunta 3 de
5 ou na 3 de 30, e as decisões tomadas vivem só na conversa: se o contexto
compacta no meio de um grill longo, o que foi decidido nos primeiros blocos se
perde.

## Solution

O grill passa a perguntar pela ferramenta de pergunta do harness:

1. Antes da primeira pergunta, avisa quantas perguntas estima fazer. Quando a
   árvore de decisões cresce, avisa a estimativa nova.
2. Pergunta em blocos de até 10. Cada pergunta tem um título curto, opções
   enxutas e a recomendada marcada, com uma linha de porquê. O bloco é quebrado
   em quantas chamadas o limite do harness exigir.
3. Ao fim de cada bloco, grava as decisões num arquivo de discovery e mostra no
   chat um resumo de uma linha por decisão.
4. Quando não sobra pergunta, faz um último prompt com todas as decisões e pede
   a confirmação do entendimento comum, que o upstream já exige antes de agir.
5. Toda pergunta tem, entre as opções, uma marcada como a recomendada pelo grill
   e uma opção custom, para o operador escrever a própria resposta àquela
   pergunta. Isso vale também para o último prompt e para o fallback.
6. Sem ferramenta de pergunta disponível, como no Codex fora do modo Plan, usa
   um texto compacto: uma linha por pergunta, com alternativas `a`/`b`/`c` mais
   a custom, e o operador responde `1a 2c 3b`.

O resto do `anvil-grilling` fica verbatim: árvore de decisões, frontier, fatos
buscados por subagente e critério de término.

## User Stories

1. Como operador, quero que o grill me faça perguntas com opções clicáveis, para escolher sem redigir prosa.
2. Como operador, quero que toda pergunta traga uma opção marcada como a recomendada pelo grill, para aceitar a recomendação com um clique quando concordo.
3. Como operador, quero uma linha de porquê junto da recomendação, para decidir sem pedir explicação.
4. Como operador, quero que toda pergunta traga uma opção custom em que eu escrevo minha resposta, para não ser forçado a uma alternativa que não serve.
5. Como operador, quero saber antes de começar quantas perguntas o grill estima, para decidir se faço agora ou depois.
6. Como operador, quero ser avisado quando a estimativa cresce, para não achar que o grill está em loop.
7. Como operador, quero receber no máximo 10 perguntas por bloco, para não encarar um paredão.
8. Como operador, quero ver no chat, ao fim de cada bloco, uma linha por decisão tomada, para conferir o que ficou registrado.
9. Como operador, quero que as decisões de cada bloco fiquem gravadas num arquivo, para não perdê-las se a conversa compactar.
10. Como operador, quero que o grill releia esse arquivo quando perder o contexto, para não refazer perguntas já respondidas.
11. Como operador, quero um último prompt com todas as decisões juntas, para confirmar o entendimento comum de uma vez.
12. Como operador, quero poder pedir ajuste nesse último prompt, para corrigir uma decisão sem recomeçar o grill.
13. Como operador no Codex fora do modo Plan, quero um formato de texto compacto, para responder rápido mesmo sem ferramenta de pergunta.
14. Como operador no Claude Code, quero que um bloco de 10 chegue em chamadas seguidas, sem que o grill reduza o bloco por causa do limite de 4 perguntas por chamada.
15. Como operador, quero que perguntas que dependem de uma resposta ainda aberta continuem para o bloco seguinte, para não responder no escuro.
16. Como operador do `anvil-bench`, quero continuar recebendo uma pergunta por vez, porque é o ritmo que o bench declara para quem não programa.
17. Como operador do piloto automático, o `anvil-auto`, quero o mesmo formato no grill de entrada, para planejar o roteiro inteiro do mesmo jeito.
18. Como mantenedor do anvil, quero que a mudança na skill vendorizada seja uma regra declarada no catálogo, para o sync sinalizá-la a cada merge com o upstream.
19. Como mantenedor do anvil, quero um ADR que explique por que essa mudança é adaptação e não uma rule do projeto, para que ninguém a desfaça achando que viola o `ADR-0001` — as skills vendorizadas seguem o padrão original.
20. Como mantenedor do anvil, quero o delta restrito ao trecho de formato da rodada, para o merge 3-way continuar quase trivial.
21. Como mantenedor do anvil, quero que o `vendor-sync.sh verify` continue passando, para a regra nova não quebrar a verificação de antes do commit.

## Implementation Decisions

### A regra nova no catálogo

- Entra no catálogo de adaptações uma regra de **julgamento** chamada
  `ask-rounds`, aplicada à mão como o `docs-remap`, o `decursor`, o
  `tracker-profile` e o `verification-profile`. O `vendor-sync.sh` passa a
  sinalizá-la em "FALTA APLICAR À MÃO" e em "revise as regras de julgamento",
  como já faz com as outras quatro.
- O manifesto declara `ask-rounds` só no `anvil-grilling`. O `anvil-grill` e o
  `anvil-grill-me` só chamam o `anvil-grilling` e não mudam.
- A entrada no catálogo diz por que a regra existe, mostra o diff curto do seam e
  delimita o escopo. A versão do anvil ganha num merge em que o upstream mexa no
  formato da rodada; o resto do arquivo fica verbatim.
- Um ADR novo, o próximo da sequência, registra a decisão. O `ADR-0001` diz que a
  incoerência se resolve por perfil ou rule, nunca no arquivo da skill. O ADR novo
  explica por que aqui não dá: o `anvil-grilling` prescreve o formato de texto
  literalmente, e uma diretiva que contradiz a skill perde. É o mesmo argumento
  que o `verification-profile` usa em relação ao brief do subagente. O
  `ADR-0001` não é revogado, e o ADR novo abre uma exceção nomeada, como o
  `ADR-0010` fez.

### O delta no `anvil-grilling`

O delta fica só no parágrafo "Work the tree in rounds…" e no bloco "Format a
round like so". Árvore, frontier, fatos por subagente e término ficam intactos.

- **Rodada e bloco.** A rodada continua sendo a frontier do upstream. Uma
  frontier com mais de 10 perguntas é quebrada em blocos de 10. Uma frontier
  menor é um bloco só, e o grill não completa o bloco com perguntas cujo
  pré-requisito ainda está aberto.
- **Estimativa.** Antes do primeiro bloco, o grill conta os nós conhecidos da
  árvore e avisa "cerca de N perguntas". Quando uma resposta abre ramos novos e a
  contagem sobe, ele avisa a estimativa nova no início do bloco seguinte.
- **Ferramenta.** O texto da skill nomeia o `AskUserQuestion`, que é o
  vocabulário do Claude Code e o mesmo que o `decursor` usa. A rule de harness do
  omp já mapeia esse nome para o `ask`. A skill também cita o
  `request_user_input` como equivalente no Codex.
- **Quebra por limite.** O bloco é enviado em quantas chamadas seguidas o limite
  do harness exigir: no Claude Code, até 4 perguntas por chamada e de 2 a 4
  opções; no omp, o bloco inteiro numa chamada.
- **Forma da pergunta.** Cada pergunta tem um título de até 12 caracteres, um
  enunciado de uma ou duas frases e as opções. Duas opções são obrigatórias em
  toda pergunta, sem exceção:
  - **a recomendada:** vem primeiro, marcada como recomendada, com uma linha de
    porquê na descrição. Pergunta sem recomendação não sai: se o grill não tem
    opinião, recomenda a opção mais conservadora e diz isso no porquê;
  - **a custom:** uma opção para o operador escrever a própria resposta àquela
    pergunta. Onde a ferramenta já a oferece sozinha, como o "Other" do
    `AskUserQuestion` e do `ask`, o grill usa a nativa e não a duplica. Onde a
    ferramenta não a oferece, o grill acrescenta uma opção explícita
    "Escrever minha resposta". Como ela ocupa uma vaga, sobram no máximo 3
    alternativas no limite de 4 opções.

  Uma pergunta aberta, como um nome ou um número, vira a sugestão recomendada do
  grill mais a custom.
- **Fallback.** Sem ferramenta, ou quando a chamada falha porque o modo do
  harness não a oferece, o bloco sai em texto compacto: uma linha por pergunta,
  no formato `N. <título> — a) … b) … x) escreva a sua  ➡️ <letra recomendada>:
  <porquê>`. O operador responde `1a 2c 3b`, ou `3x: <texto>` para a custom, e o
  que não casar com uma letra é lido como resposta custom daquela pergunta.
- **Confirmação final.** Com a frontier vazia, o grill faz um último prompt pela
  mesma ferramenta, ou pelo fallback. O prompt traz o resumo de todas as decisões
  e as opções "confirmar", que é a recomendada, e "ajustar", mais a custom.
  "Ajustar" pergunta qual decisão reabrir e
  volta àquele ramo. Esse prompt substitui a confirmação em prosa que o upstream
  pede antes de agir.

### O arquivo de registro

- **Onde.** Segue o modelo de pastas do `anvil-docs`: fora de branch de spec,
  `docs/discovery/grill-<slug>.md`; num branch de spec,
  `docs/specs/{NNN}-{tipo}-{nome}/discovery/grill-<slug>.md`. O `<slug>` é
  kebab-case e vem do assunto do grill. A pasta nasce no primeiro registro.
- **O que grava.** O arquivo é só de acréscimo. Cada bloco vira uma seção
  `## Bloco N`, com uma linha por pergunta: título, decisão e se a recomendação
  foi aceita ou não. A confirmação final vira uma seção `## Confirmação`, com o
  resumo confirmado.
- **Quando.** O grill grava ao fim de cada bloco, antes de mostrar o resumo no
  chat. Se o contexto se perdeu, o grill relê o arquivo antes do bloco seguinte e
  não repete pergunta registrada.
- **Commit.** O grill escreve e não commita. Quem commita é o operador, ou o
  piloto automático no fluxo dele.
- O `anvil-docs` já lista o `anvil-grill` como escritor de `discovery/`. Só a
  linha do grill no `README.md` de `docs/discovery/` ganha a menção ao registro
  do grill.

### Interação com quem chama o grill

- **`anvil-bench`.** Continua mandando "uma pergunta por vez". A instrução do
  bench vale sobre o tamanho do bloco: blocos de 1, com a mesma ferramenta, o
  mesmo registro e a mesma confirmação final.
- **`anvil-auto`, `anvil-plan` e `anvil-wayfinder`.** Não mudam. Herdam o
  formato porque carregam o `anvil-grilling`. O piloto continua tratando a
  confirmação final como o único sim do operador, conforme o `ADR-0014` — o
  piloto automático fecha sem humano.

## Testing Decisions

- Não há suíte. A verificação automática é
  `bash .claude/skills/anvil-sync/scripts/vendor-sync.sh verify`, que precisa
  passar com a regra nova no manifesto. A medida de delta do `anvil-grilling`
  contra o pin deve ficar restrita ao trecho de formato da rodada.
- O comportamento se prova num cenário manual em `workspace/`, fora do git, como
  os cenários `01-…08-`. Um grill sobre um plano com mais de 10 decisões é rodado
  em três harnesses:
  - **Claude Code:** estimativa anunciada; bloco de 10 em três chamadas do
    `AskUserQuestion`; resumo no chat; arquivo de discovery com `## Bloco 1`;
    confirmação final por ferramenta.
  - **omp, pelo `dev-run.sh -- omp`:** o mesmo, com o bloco numa chamada do
    `ask`.
  - **Codex no modo padrão:** o fallback em texto compacto, com resposta
    `1a 2c 3b` lida corretamente e `3x: <texto>` registrado como resposta
    custom.
- **Opções obrigatórias:** nos três harnesses, inclusive na confirmação final,
  toda pergunta mostra uma opção marcada como recomendada e uma custom, e nenhuma
  aparece em dobro. A resposta escrita na custom chega ao arquivo de discovery
  como a decisão daquela pergunta.
- **Caso de compactação:** com o arquivo de discovery já tendo um bloco, abrir
  uma sessão nova e retomar o grill. A pergunta registrada não volta.
- **Caso do bench:** o `anvil-bench` continua fazendo uma pergunta por vez, agora
  pela ferramenta.
- O que se observa é o que o operador vê e o que fica no disco, nunca a redação
  da skill.

## Out of Scope

- Mudar o `anvil-grill`, o `anvil-grill-me` ou o `anvil-domain-modeling`.
- Mudar o ritmo de uma pergunta por vez do `anvil-bench`.
- Ligar o `request_user_input` fora do modo Plan no Codex. Isso depende da
  [issue #29104](https://github.com/openai/codex/issues/29104) do upstream do
  Codex.
- Gerar a spec a partir do arquivo de discovery. O `anvil-to-spec` continua
  sintetizando a conversa, e pode ler o arquivo, mas a spec não muda o
  `anvil-to-spec`.
- Usar a ferramenta de pergunta em outras skills que hoje perguntam em texto.

## Further Notes

- Vale propor a mudança ao upstream, o `grilling` do mattpocock. Se ela entrar lá,
  a regra `ask-rounds` sai do manifesto no sync seguinte, e o delta volta a zero.
- O limite de 10 por bloco é do anvil. Ele não está ligado ao limite de 4 por
  chamada do Claude Code, que só define em quantas chamadas o bloco sai.
- Estado do Codex consultado em 2026-10-28: o `request_user_input` existe desde a
  0.88.0, mas por padrão só nos modos Plan e Pair Programming.
