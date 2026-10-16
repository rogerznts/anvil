# 008 — Piloto automático: do grill ao fechamento sem pausa humana

**Status:** ready-for-agent

Implementa o ADR-0014, segundo o qual o piloto automático leva o roteiro ao
fechamento sem humano
(`docs/architecture/adr/adr-0014-piloto-automatico-fecha-sem-humano.md`). As
fontes são a proposta `docs/discovery/bench-autonomo.md` e as decisões do grill
gravadas em `docs/discovery/piloto-automatico-decisoes-do-grill.md`, seção
"Decisões da 008". Os termos **Piloto automático**, **Roteiro**, **Condutor** e
**Frontier** são os de `docs/architecture/context.md`.

## Problem Statement

Quem usa o anvil no omp para construir algo que ocupa várias specs passa a
conversa inteira ao lado do agente. A `anvil-plan` para a cada etapa esperando um
sim. A `anvil-run` para em "todos resolvidos" e deixa archive, PR e merge com o
operador. Cada spec nova pede outro grill. Um app de ponta a ponta quase nunca
cabe numa spec, e quem pediu fica preso à conversa até o fim, respondendo a
pausas cuja resposta já estava no combinado.

O `anvil-bench` é o caso mais grave. Quem conversa com ele não programa e não tem
como responder às pausas técnicas. O bench só roda sozinho na fase de construção,
não fala de branch, archive nem merge, e deixa as specs abertas. O teto dele é de
três tentativas por ticket, contra as duas rodadas do ADR-0010 (a verificação
tem critério de parada, e a terceira rodada é escolha declarada de um humano). Ele
grava `briefing.md`, `checklist.yaml` e `gates.md` dentro de uma spec só, e com
isso não sabe dividir um app em várias.

Também não existe um lugar em disco onde o plano de várias specs viva em formato
que uma máquina leia. O `docs/project/plan.md` é prosa escrita à mão, o `map.md`
do wayfinder cobre uma spec só, e o `docs/index.md` é gerado.

## Solution

Uma skill nova da camada omp, `anvil-auto`, com trava de invocação. O operador a
chama com o pedido. O piloto conduz um único ponto de entrada humano, que é o
`anvil-grill` num projeto comum ou a entrevista do bench, e cobre ali o plano
inteiro: as specs, a ordem, o escopo e o critério de pronto de cada uma. No fim da
entrada, ele escreve o **roteiro** em `docs/specs/roadmap.md`, mostra o roteiro e
pede a confirmação do entendimento sobre o texto escrito. Esse é o único sim da
execução.

Depois do sim, o piloto conduz sem pausa. Ele pega a entrada do frontier do
roteiro, abre o branch pelo `new-spec.sh` e roda `anvil-to-spec`,
`anvil-to-tickets` e o laço de despacho da `anvil-run`. Às pausas das skills de
etapa ele responde sozinho, e cada resposta vai para o relatório. A spec só fecha
com `PASS`: archive, e depois merge local ou PR, conforme a regra do projeto. Uma
spec que não fecha sozinha fica aberta no branch dela. A corrente segue pelas
entradas que não dependem dela e termina quando não sobra entrada desbloqueada.

Antes de travar numa parada técnica, o piloto pesquisa em fontes primárias. Se a
pesquisa traz evidência nova, ele abre uma rodada a mais, uma só. Parada por
decisão, como gate manual, PR ou contradição com o roteiro, não pesquisa: vai
direto para o relatório.

A saída é `docs/specs/report.md`, com o que foi feito, o que foi decidido sem
humano e onde a corrente parou. O relatório termina em "o que ainda espera
decisão", com cada item escrito como pergunta. Essa lista é a pauta da oferta de
grill novo.

O estado de cada entrada do roteiro não é gravado: um script deriva esse estado do
disco. O mesmo script alimenta o piloto e a seção do roteiro no `docs/index.md`.

O bench passa a ser a entrada do piloto para quem não programa. No Claude Code, ou
chamado direto, o bench constrói a primeira entrada e para no fim da construção,
como hoje. O relatório dele diz então que o fechamento ficou com o operador.

A `anvil-plan` e a `anvil-run` não mudam.

## User Stories

### Entrada

1. Como operador no omp, quero chamar `/skill:anvil-auto` com o pedido e
   participar só do grill, para que um app de várias specs saia de uma conversa
   só.
2. Como operador, quero que o grill cubra o plano inteiro (as specs, a ordem, o
   escopo, o que fica de fora e o critério de pronto de cada uma), para não ser
   chamado de volta entre uma spec e outra.
3. Como operador, quero ver o roteiro escrito antes de confirmar, para que o meu
   sim valha sobre o texto que o piloto vai executar, e não sobre a minha memória
   da conversa.
4. Como operador, quero que a confirmação do roteiro seja o único sim da execução,
   para não precisar ficar de guarda na sessão.
5. Como operador, quero que o roteiro confirmado seja commitado na `main` antes do
   branch da primeira spec, para que o combinado sobreviva a uma queda da sessão.
6. Como operador, quero que um anexo meu, como um PDF ou uma planilha, seja
   copiado para `docs/discovery/` ou tenha o texto extraído para lá antes de ser
   usado, para que a decisão tirada dele seja rastreável no repositório.
7. Como operador num projeto que já tem um roteiro inacabado, quero que o grill
   novo parta desse roteiro e o edite, para não haver dois planos concorrentes.
8. Como operador, quero que um roteiro novo que descarta entradas inacabadas seja
   recusado até eu abandoná-las de forma explícita no grill, para que nenhuma spec
   em andamento suma do plano sem que eu saiba.
9. Como operador, quero que o piloto recuse a largada com a árvore suja, antes de
   escrever qualquer arquivo, para que nada meu entre num commit dele.
10. Como operador de um projeto sem comando de verificação declarado, quero uma
    recusa na largada que diga onde declará-lo, para que nenhuma spec feche sem
    prova executada.
11. Como operador num projeto com outro perfil de tracker, quero a mesma recusa
    dos condutores, para saber que o fluxo ali segue à mão.
12. Como operador que chama o piloto no branch de uma spec aberta, quero que ele
    retome essa spec do ponto em que o disco diz que ela está e depois siga a
    corrente, para não perder trabalho já feito.
13. Como operador, quero que o piloto tenha trava de invocação, para que nenhum
    modelo o dispare por conta própria.

### Roteiro

14. Como operador, quero o roteiro num arquivo de formato fixo em
    `docs/specs/roadmap.md`, para que o piloto e o índice leiam a mesma coisa.
15. Como operador, quero que cada entrada traga o tipo, o nome, o que entra, o que
    fica de fora, o critério de pronto e as dependências, para que cada spec nasça
    com o escopo já fechado.
16. Como operador, quero que a entrada ganhe `Spec: NNN` quando a spec dela nasce,
    para que eu saiba qual pasta e qual branch são dela.
17. Como operador, quero que o estado de cada entrada (pendente, em andamento,
    fechada ou parada) saia do disco e não de um campo gravado, para que ele nunca
    minta depois de um merge feito à mão.
18. Como operador, quero ver o roteiro no `docs/index.md`, acima das specs ativas,
    com o estado de cada entrada, para saber em que pé o plano está sem abrir
    branch nenhum.
19. Como operador, quero que um roteiro com dependência para entrada inexistente,
    com ciclo ou com nome repetido seja recusado com o motivo, para não começar uma
    corrente que não pode terminar.
20. Como operador, quero o histórico do roteiro no git, sem arquivo de versão,
    para ver o plano de antes pelo log.

### Corrente

21. Como operador, quero que o piloto pegue sempre a próxima entrada cujas
    dependências já fecharam, na ordem do roteiro, para que a construção respeite o
    que foi combinado.
22. Como operador, quero que cada spec nasça num branch novo saído da `main` pelo
    `new-spec.sh`, para manter a numeração atômica e o fluxo git do projeto.
23. Como operador, quero que o piloto rode `anvil-to-spec` e `anvil-to-tickets`
    como estão e responda sozinho às pausas delas, como a checagem dos seams e a da
    granularidade, para que a spec e os tickets saiam no mesmo formato de sempre.
24. Como auditor, quero cada pausa respondida pelo piloto no relatório, com a
    pergunta e a resposta, para saber o que foi decidido sem humano.
25. Como operador, quero que a implementação use o laço de despacho da
    `anvil-run`, com o `frontier.sh` e um `anvil-implementer` por ticket, para que
    uma correção no laço valha para os dois fluxos.
26. Como operador, quero que o piloto nunca mude o escopo nem o critério de pronto
    de uma entrada, para que o combinado no grill continue sendo a régua.
27. Como operador, quero que um conflito entre o código e o roteiro que ainda deixa
    o critério cumprível seja resolvido dentro da spec e registrado como "decidido
    sem humano", para que a corrente não pare por detalhe.
28. Como operador, quero que um conflito que torna o critério incumprível pare a
    entrada e vá para "o que ainda espera decisão", para que nenhuma spec feche
    sobre um critério que eu não reconheceria.
29. Como operador, quero que uma spec parada não pare a corrente inteira, e que o
    piloto siga com as entradas que não dependem dela nem direta nem indiretamente,
    para aproveitar a execução.
30. Como operador, quero que a corrente termine quando não sobra entrada
    desbloqueada, para que a execução tenha fim sem eu interromper.
31. Como operador, quero que o piloto conduza uma execução por vez, spec por spec,
    para que o estado no disco tenha um escritor só.

### Fechamento

32. Como operador, quero que uma spec só feche com `PASS`, para que o piloto nunca
    feche trabalho que não provou.
33. Como operador fora do bench, quero que o `PASS` exija todos os tickets
    `resolved`, a última `Review:` de cada um em `verdict=pass; p1=none` e o
    comando de verificação das rules saindo `0` quando rodado pelo próprio piloto,
    para que a prova seja a execução e não o que o implementer disse.
34. Como operador, quero que o fechamento siga a regra do meu projeto, para que o
    piloto não invente um fluxo git.
35. Como operador de um projeto que fecha por PR, quero que o piloto arquive, abra
    o PR e pare sem fazer merge, para que a revisão do PR continue sendo minha.
36. Como operador de um projeto sem PR, quero que o piloto arquive e faça o merge
    local na `main`, para que a próxima spec já parta do código da anterior.
37. Como operador, quero que a guarda de merge valha para o piloto como vale para
    mim, sem contorno, para que um fechamento indevido seja bloqueado do mesmo
    jeito.
38. Como operador, quero que um conflito de merge só no `docs/index.md` seja
    resolvido gerando o índice de novo, e que qualquer outro conflito deixe a spec
    parada, para que o piloto não resolva conflito de código sozinho.
39. Como operador, quero que tudo o que depende de uma spec com PR aberto espere o
    merge do PR, para que nenhuma spec seja construída sobre código que ainda não
    está na `main`.

### Pesquisa antes de travar

40. Como operador, quero que, numa parada técnica (ticket travado em `round=2`,
    verificação que falha no `PASS`, implementer bloqueado por fato desconhecido
    ou `FAIL` no teto do bench), o piloto rode o `anvil-research` contra fontes
    primárias antes de desistir, para não parar por falta de uma informação
    pública.
41. Como auditor, quero o achado da pesquisa gravado em
    `docs/specs/{id}/discovery/`, para que a rodada extra tenha evidência
    citável.
42. Como operador, quero que o piloto abra uma rodada a mais, uma só, apenas
    quando a pesquisa trouxer evidência nova, isto é, uma fonte citada que explica
    a falha e ainda não está no ticket, e que registre no ticket que abriu a rodada
    e por qual arquivo, para que a exceção ao ADR-0010 seja declarada.
43. Como operador, quero que os sinais de laço de `docs/agents/verification.md`
    bloqueiem essa rodada mesmo com evidência, para que a pesquisa não vire
    insistência.
44. Como operador, quero que a parada por decisão (gate manual, PR, contradição
    com o roteiro) não dispare pesquisa e vá direto para o relatório, para não
    gastar uma execução procurando na web o que só eu decido.

### Relatório e grill novo

45. Como auditor, quero um relatório único da execução em `docs/specs/report.md`,
    para ler a corrente inteira num lugar só.
46. Como auditor, quero que o relatório seja escrito à medida que a corrente
    avança e commitado na `main` a cada fronteira de spec, para que uma queda da
    sessão não leve o que já foi feito.
47. Como auditor, quero no relatório cada pausa autoaprovada com a resposta, os
    tickets com `Status` e linhas `Review:`, os P2/P3 que ficaram, os travados em
    `round=2`, a saída do comando de verificação e as pesquisas feitas, para
    auditar sem abrir cada branch.
48. Como operador, quero que o relatório diga em que entrada a corrente parou e por
    quê, para saber por onde retomar.
49. Como operador, quero que o relatório termine em "o que ainda espera decisão",
    com cada item escrito como pergunta, para que o grill novo comece com a pauta
    pronta.
50. Como operador, quero que o piloto me ofereça um grill novo com essa pauta no
    fim, para fechar as pendências sem montar o contexto de novo.
51. Como operador, quero o relatório linkado no `docs/index.md` ao lado do
    roteiro, para achá-lo sem saber o caminho.

### Bench

52. Como pessoa que não programa, quero que a entrevista do bench seja o único
    ponto em que eu participo, para receber a ferramenta sem responder a perguntas
    técnicas.
53. Como pessoa que não programa, quero ver o roteiro em português simples (o que
    vai ser feito, em que ordem e como vou saber que cada parte está pronta) e
    confirmar sobre esse texto, para entender o que estou aprovando.
54. Como operador do bench, quero o `roadmap.md` técnico gravado ao lado, fora da
    conversa, para que o piloto leia o mesmo formato de qualquer projeto sem
    quebrar o INV-6 (quem pediu não vê jargão, log nem comando).
55. Como operador do bench, quero que a entrevista leia os documentos que o
    projeto já tem antes de perguntar, para não perguntar o que está escrito.
56. Como operador do bench, quero o `briefing.md` em `docs/discovery/` e o
    `checklist.yaml` em `docs/qa/`, como documentos da ferramenta e não de uma
    spec, para que várias specs leiam o mesmo combinado.
57. Como operador do bench, quero que cada entrada do roteiro diga quais itens do
    checklist ela cobre, e que cada spec tenha o seu `gates.md` só com esses itens,
    para que o `PASS` de uma spec meça o que ela prometeu.
58. Como operador do bench, quero que o `PASS` da spec k reexecute o `gates.md`
    dela e o de cada spec do roteiro já fechada, para que uma spec nova não quebre
    o que já foi entregue.
59. Como operador do bench, quero que um gate manual pertença à entrada que cobre
    o item e segure o fechamento dela, indo para o relatório com a pergunta
    formulada, para que nada sem prova feche sozinho.
60. Como operador do bench, quero que o teto passe de três tentativas para as duas
    rodadas do ADR-0010, também no bench manual, e que o ticket travado vire
    `CONCERNS` com pendência no relatório, para que o bench siga a mesma régua do
    resto do anvil.
61. Como operador do bench, quero que uma construção começada fora do bench, sem
    `checklist.yaml` nem `gates.md`, seja retomada refazendo só a fase 4 a partir
    da spec e dos tickets existentes, e, sem spec, com a fase 3 como entrevista do
    delta, para não refazer o que já existe.
62. Como operador do bench, quero que o relatório traga o `decisions-log.md` e
    ganhe uma versão em português simples no chat, para que a pessoa e o auditor
    leiam a mesma execução cada um no seu nível.
63. Como operador do bench no Claude Code sem omp, quero que o bench construa a
    primeira entrada do frontier e pare no fim da construção, sem recusar, com o
    relatório dizendo que o fechamento ficou comigo e listando archive e merge,
    para saber o que falta fazer à mão.
64. Como operador, quero que o piloto entre pela entrevista do bench quando o
    projeto já tem a rule da stack do bench ou quando eu o chamo com `--bench`, e
    pelo `anvil-grill` nos outros casos, para que a entrada seja decidida por um
    sinal claro.

### Instalação e documentação

65. Como operador, quero o `anvil-auto` instalado junto com o resto da camada omp,
    sem passo extra, para que ele chegue como chegam a `anvil-plan` e a
    `anvil-run`.
66. Como operador, quero o piloto descrito no manual `anvil-omp`, com o que ele faz
    sozinho e o que nunca faz, para saber o que estou delegando.
67. Como mantenedor, quero que o `vendor-sync.sh verify` cubra o `anvil-auto` como
    cobre os outros condutores, para que um caminho quebrado na skill não chegue à
    instalação.
68. Como operador de projeto novo, quero que o `anvil-boot` grave o comando de
    verificação sob o título que o piloto lê, para que o projeto não seja recusado
    na largada.

## Implementation Decisions

### Peças

- **Skill nova `anvil-auto`, na camada omp**, ao lado de `anvil-plan` e
  `anvil-run`, com `disable-model-invocation: true`. Ela é instalada pelo mesmo
  caminho dos outros arquivos da camada. A skill é prosa de condução: lê o estado
  pelos scripts, carrega as skills de etapa com o `read` em `skill://<nome>`,
  despacha implementers pelo `task` e escreve o relatório. O verbete **Condutor**
  não muda: o piloto é peça à parte.
- **A `anvil-plan` e a `anvil-run` não mudam.** O piloto reusa o `stage.sh`, o
  `frontier.sh` e o laço de despacho descrito na `anvil-run`, mas a prosa dele é
  própria. Nenhuma regra "nunca" das duas ganha exceção.
- **Script novo de estado do roteiro, `roadmap.sh`, no núcleo, dentro de
  `anvil-docs`.** Fica no núcleo porque o verbo `index` do `anvil-docs` o lê, e o
  verbo roda em qualquer harness. O piloto o chama pela instalação de usuário,
  como o bench já chama scripts do núcleo. Ele não escreve nada.
- **Bench (`anvil-bench`, skill autoral):** mudam o `SKILL.md`, o `GATE.md` e, se
  o formato de cobertura pedir, o `CHECKLIST.md`. O material em `unlazy/` é
  vendorizado e não muda: o formato do `gates.md`, o `gate-check.mjs` e o
  `gate-lint.mjs` ficam como estão.
- **`anvil-docs`:** o verbo `index` e o template do índice ganham a seção do
  roteiro. O template do perfil do tracker e o `README` de `docs/specs/`
  registram que `roadmap.md` e `report.md` moram em `docs/specs/`, fora das
  pastas de spec.
- **`anvil-boot`:** grava o comando de teste do projeto em `.claude/rules/anvil.md`
  sob o título `## Comando de verificação`, com um bloco `bash`, no formato que
  este repositório já usa.
- **Diretivas** (o bloco do payload e a rule da camada omp que o espelha): a
  "Cauda de roteamento" ganha uma linha na lista de quando a cauda não dispara,
  que é dentro de uma execução do `anvil-auto`, porque quem decide o próximo passo
  ali é o piloto. O `anvil-auto` não entra na lista de skills com cauda: o fim
  dele é a oferta de grill novo.

### Formato do roteiro

Um arquivo, `docs/specs/roadmap.md`, com um roteiro ativo por projeto. Cada
entrada é uma seção de segundo nível cujo título é o **nome** da entrada, em
kebab-case e único no arquivo. Esse nome é o `--short-name` que o piloto passa ao
`new-spec.sh` e é também o que as outras entradas citam em `Depende de:`. As
chaves são linhas `Chave: valor` no começo da linha, com ou sem negrito, como o
`Status:` dos tickets:

```markdown
# Roteiro

## cadastro-de-clientes

Tipo: feature
Depende de:
Cobre: C1, C2, C3
Spec: 009

Entra: cadastro, busca e edição de clientes.
Fica de fora: importação de planilha.
Pronto quando: um atendente cadastra, encontra e corrige um cliente.

## pedidos

Tipo: feature
Depende de: cadastro-de-clientes

Entra: …
Fica de fora: …
Pronto quando: …
```

- `Tipo:` é um dos tipos do `new-spec.sh`.
- `Depende de:` é uma lista de nomes separados por vírgula. Vazia ou ausente quer
  dizer sem dependência.
- `Cobre:` traz os ids do `checklist.yaml` e só existe no bench.
- `Spec:` não existe enquanto a spec não nasce. Só o piloto o escreve.
- `Entra:`, `Fica de fora:` e `Pronto quando:` vêm do grill. O piloto nunca os
  edita.
- A ordem das seções é a ordem do roteiro e desempata o frontier.
- O estado não é gravado. O arquivo não tem `Status:`.

### `roadmap.sh`: estado derivado e frontier

Saída em linhas `chave: valor`, como o `stage.sh` e o `frontier.sh`. Os valores
de estado são identificadores em inglês, e o índice os mostra em português.

- `roadmap: docs/specs/roadmap.md`, ou `roadmap: none` quando não há arquivo. Sem
  arquivo, a saída é `next: none`.
- Uma linha `entry:` por entrada, na ordem do arquivo, com `state`, `spec`,
  `depends` e `reason`.
- `frontier:`, com as entradas `pending` cujas dependências estão todas `closed`,
  na ordem do arquivo, menos as que vierem em `--skip`.
- `next:`, com a primeira do frontier, ou `none`.
- `refusal:`, com o motivo, quando há nome repetido, `Depende de:` que aponta para
  nome inexistente, ciclo ou `Tipo:` inválido. Com recusa, não há frontier.

Derivação, lida do checkout atual e, para spec aberta, do commit do branch local
de spec com o mesmo número, sem trocar de checkout (a mesma técnica do
`validate.sh` da guarda):

| estado | condição |
|---|---|
| `pending` | sem `Spec:` |
| `closed` | pasta `docs/specs/archive/{NNN}-*` no checkout atual, ou seja, já está na `main` |
| `open` | spec achada fora de `archive/`, sem `spec.md`, sem tickets, ou com algum ticket a despachar |
| `stopped` | spec achada e não fechada, sem ticket a despachar: todos `resolved`, ou os não resolvidos travados (última `Review:` com `round` 2 ou mais e `verdict=fail`) ou dependentes de travado; também a spec arquivada no branch e ainda sem merge (PR aberto) e o `Spec:` cuja pasta e cujo branch não existem, cada um com o seu `reason` |

Como o piloto conduz uma execução por vez, uma spec aberta sem nada a despachar,
lida fora de uma execução, é uma spec em que a última execução não fechou. Uma
entrada que depende transitivamente de uma `stopped` nunca entra no frontier,
porque alguma dependência dela nunca chega a `closed`.

`--skip "a b"` tira entradas do frontier só para aquela chamada. O piloto o usa
para a entrada em que parou antes de criar a spec, na mesma execução, como a
`anvil-run` faz com os tickets pulados.

### Largada

Na ordem, antes de escrever qualquer arquivo:

1. Perfil do tracker que não é o `docs/specs` gera a mesma recusa e o mesmo texto
   do `stage.sh` e do `frontier.sh`.
2. Árvore suja gera recusa.
3. Fora do bench, um `.claude/rules/anvil.md` sem `## Comando de verificação`
   gera recusa, e a mensagem diz onde e como declarar o comando.
4. Num branch de spec com a spec aberta, o piloto retoma: o `stage.sh` diz a etapa
   do planejamento, e o `frontier.sh` diz o que falta construir. Depois o piloto
   segue a corrente a partir da `main`. Num branch de spec arquivada, ou num
   branch sem número que não é a `main`, ele recusa e aponta a `main`.
5. Na `main`, o piloto passa pela entrada.

Uma execução por vez por projeto. Não há trava em arquivo (ADR-0003, sem máquina
de fases: o artefato é o estado). Duas execuções no mesmo checkout são erro de
operação, e o manual diz isso.

### Entrada

- O piloto entra pela entrevista do bench quando o projeto tem a rule da stack do
  bench (o sinal da fase 2 do bench) ou quando é chamado com `--bench`. Nos
  outros casos, entra pelo `anvil-grill`, com o pedido como ponto de partida.
- Anexo da pessoa é copiado, ou tem o texto extraído, para `docs/discovery/`
  antes de ser usado.
- O grill cobre o plano inteiro. Com um roteiro já existente que tem entrada não
  `closed`, o grill parte dele e o edita: acrescenta, reordena ou abandona
  entradas. Abandonar é tirar a entrada do arquivo, e o histórico fica no git. Um
  roteiro que substitui o anterior só é aceito quando toda entrada não `closed`
  foi abandonada de forma explícita no grill.
- No fim, o piloto escreve o `roadmap.md`, roda o `roadmap.sh` sobre ele (uma
  recusa volta ao grill) e mostra o roteiro. No bench, mostra a versão em
  português simples. A confirmação do entendimento é sobre esse texto e é o único
  sim. Depois dela, o piloto commita o roteiro na `main`.

### Corrente

Laço do piloto, com o estado sempre relido do disco:

1. Rode o `roadmap.sh`. Com `next: none`, vá para o fim.
2. Antes de criar a spec, confira a entrada contra o código atual. Se o critério
   de pronto já é incumprível, ponha a entrada no `--skip` desta execução e a
   contradição em "o que ainda espera decisão", e volte ao passo 1.
3. Na `main`, rode `new-spec.sh --type <Tipo> --short-name <nome> --json`. Volte à
   `main`, grave `Spec: NNN` na entrada e commite. Avance o branch da spec, que
   ainda não tem commit, até esse commit e volte a ele. Assim o `Spec:` existe na
   `main` mesmo que a spec nunca feche, e nenhuma execução seguinte cria spec em
   dobro para a mesma entrada.
4. No bench, rode a fase 4 desta spec: o `gates.md` só com os itens de `Cobre:`,
   os testes derivados deles e o `gate-lint`.
5. `anvil-to-spec`, com a entrada do roteiro como contexto, e depois
   `anvil-to-tickets`. O piloto responde às pausas delas escolhendo a opção
   recomendada pela skill ou, sem recomendação, a mais conservadora, e registra
   pergunta e resposta no relatório. A cauda de roteamento não dispara.
6. Laço de despacho igual ao da `anvil-run`: `frontier.sh`, um `anvil-implementer`
   por ticket, em série, os pulados no `--skip` e a parada no `halt`.
7. Sem ticket a despachar: travado leva à pesquisa (abaixo). Sem travado, o
   piloto confere o `PASS`.
8. Com `PASS`, fecha. Sem `PASS`, a falha da verificação também leva à pesquisa,
   e o gate manual aberto deixa a spec parada.
9. Atualize o `report.md` na `main`, commite e volte ao passo 1.

Uma contradição achada depois que a spec nasceu, durante a spec, os tickets ou a
implementação, segue a mesma régua. Com o critério ainda cumprível, o piloto
adapta dentro da spec e registra "decidido sem humano". Com o critério
incumprível, a spec fica parada e a contradição vai para "o que ainda espera
decisão".

### `PASS` e fechamento

- **Fora do bench, `PASS`** é: todos os tickets `resolved`, a última `Review:` de
  cada um em `verdict=pass; p1=none`, e o bloco de `## Comando de verificação`
  rodado pelo piloto, na raiz, saindo `0`. A saída vai para o relatório.
- **No bench, `PASS`** é o `gate-check.mjs --reverify` rodado pelo piloto sobre o
  `gates.md` desta spec e sobre o de cada spec do roteiro já `closed`. Um gate
  manual aberto em item coberto por esta entrada segura o fechamento.
- **Fechamento**: `anvil-docs archive` no branch da spec, com commit. Depois, a
  regra do projeto (o perfil do tracker mais as rules) decide:
  - se o projeto fecha sem PR, ou não tem remoto, o piloto faz o merge local na
    `main`;
  - se fecha por PR, o piloto abre o PR pelo `tea-open-pr` e para ali, sem merge.
    A entrada fica `stopped` até o merge do PR.
- **Conflito no merge**: se o conflito é só no `docs/index.md`, o piloto gera o
  índice de novo e conclui o merge. Qualquer outro conflito aborta o merge e deixa
  a spec parada no branch.
- A guarda de merge vale sempre e não tem contorno.

### Pesquisa antes de travar

- **Parada técnica** é um ticket travado em `round=2`, a verificação que falha no
  `PASS`, um implementer bloqueado por fato desconhecido ou `FAIL` no teto do
  bench. Nela, o piloto roda o `anvil-research` contra fontes primárias da web e
  grava o achado em `docs/specs/{id}/discovery/`.
- **Evidência nova** é uma fonte citada que explica a falha e ainda não está no
  ticket. Com ela, o piloto abre uma rodada a mais, uma só por parada, no ticket
  que a evidência aponta. Ele registra no `## Comments` do ticket que abriu a
  rodada e por qual arquivo, e despacha um `anvil-implementer` para esse ticket
  com o arquivo no contexto. Se a evidência não aponta ticket nenhum, não há
  rodada.
- **Os sinais de laço** de `docs/agents/verification.md` bloqueiam a rodada mesmo
  com evidência.
- **Parada por decisão** não pesquisa: gate manual, PR e contradição com o roteiro
  vão direto para o relatório.

### Relatório

- **Arquivo** `docs/specs/report.md`, um por execução, com o histórico no git. Ele
  é commitado na `main` a cada fronteira de spec: depois do merge, quando a spec
  fica parada ou com PR aberto, e quando o piloto para antes de uma spec. O
  detalhe por ticket continua nos tickets.
- **Conteúdo**: as specs da execução, na ordem, cada uma com a entrada, o estado
  e o branch; cada pausa autoaprovada com a resposta; os tickets com `Status` e
  linhas `Review:`; os P2/P3 que ficaram; os travados em `round=2`; a saída do
  comando de verificação ou do `--reverify`; as pesquisas feitas, com o arquivo e
  com a rodada aberta ou não; e o que foi decidido sem humano. Depois vêm onde a
  corrente parou e por quê e, por último, "o que ainda espera decisão", com cada
  item escrito como pergunta.
- **No bench**, o relatório também traz o `decisions-log.md`, e o chat recebe a
  versão em português simples (INV-6).
- **Fim**: o piloto oferece um grill novo com a lista de "o que ainda espera
  decisão" como pauta. Aceita a oferta, ele volta à entrada, que edita o mesmo
  roteiro.

### Índice

O verbo `index` ganha a seção **Roteiro**, acima de "Specs ativas", só quando
`docs/specs/roadmap.md` existe. A seção tem uma linha por entrada, na ordem do
arquivo, com o estado vindo do `roadmap.sh` (pendente, em andamento, fechada,
parada com o motivo) e o link da spec quando há `Spec:`, mais o link para o
`report.md` quando ele existe. Uma recusa do script aparece como aviso na seção,
sem quebrar a geração.

### Bench

- **Fase 2, retomada.** Uma construção começada fora do bench, sem
  `docs/qa/checklist.yaml` nem `gates.md`, é retomada refazendo só a fase 4 a
  partir da spec e dos tickets existentes. Sem spec, a fase 3 vira entrevista do
  delta. O relatório registra o ponto de entrada.
- **Fase 3.** Antes de perguntar, a entrevista lê o que o projeto já tem, e o
  anexo da pessoa vai para `docs/discovery/`. A entrevista gera o roteiro com N
  entradas, e cada entrada diz em `Cobre:` quais itens do checklist cobre.
- **Fase 4.** O `briefing.md` vai para `docs/discovery/briefing.md` e o
  `checklist.yaml` para `docs/qa/checklist.yaml`, ambos congelados uma vez,
  depois da entrevista. O `gates.md`, os testes derivados e o lint passam a ser
  por spec, no começo de cada uma, só com os itens de `Cobre:`.
- **Fase 5.** O teto passa de três tentativas para as duas rodadas do ADR-0010.
  Ticket travado vira `CONCERNS`, com pendência no relatório. O `GATE.md` passa a
  dizer isso no lugar do "teto de três".
- **Bench chamado direto**, no Claude Code ou no omp sem o piloto: o bench
  constrói a primeira entrada do frontier e para no fim da construção, sem
  recusar. O relatório diz que o fechamento ficou com o operador e lista o
  archive e o merge.

### Documentação deste repositório

O manual `anvil-omp` ganha a seção do piloto, com o que ele faz sozinho e a lista
"nunca". O `SKILL.md` do `anvil-update` passa a listar o `anvil-auto` entre as
skills da camada. Também são atualizados o `docs/architecture/overview.md`, o
roster em `docs/project/plan.md` e o comentário da camada em
`anvil-skills.yaml`. O ADR-0014 não muda.

## Testing Decisions

Um bom teste observa o que o operador veria: as linhas do `roadmap.sh`, arquivos e
commits na `main` e nos branches, uma recusa com o motivo, um merge feito ou
bloqueado e o conteúdo do `report.md`. Ele não confere a redação da skill.

O repositório não tem suíte. São três seams: um novo e dois que já existem.

### S1 — `roadmap.sh` sobre repositórios de fixture (novo)

Repositórios git descartáveis, com `roadmap.md`, pastas de spec na `main`, em
`archive/` e em branches locais, e tickets com `Status:` e `Review:` já gravados.
Casos:

- sem `roadmap.md`: `roadmap: none` e `next: none`;
- entrada sem `Spec:` e sem dependência: `pending`, no frontier;
- entrada que depende de uma `pending`: fora do frontier;
- spec arquivada na `main`: `closed`, e a dependente entra no frontier;
- spec aberta só no branch dela, com ticket a despachar: `open`, lida sem trocar
  de checkout;
- spec aberta com todos os tickets `resolved` e sem archive: `stopped`;
- ticket travado em `round=2 verdict=fail` com os demais dependendo dele:
  `stopped`;
- spec arquivada no branch e sem merge: `stopped`, com motivo de PR;
- `Spec:` sem pasta nem branch: `stopped`, com motivo;
- dependente transitiva de uma `stopped`: nunca no frontier, enquanto uma entrada
  independente fica nele;
- `--skip`: a entrada pulada sai do frontier, e o `next` vai para a seguinte;
- recusas: nome repetido, `Depende de:` inexistente, ciclo e `Tipo:` inválido.

Prior art: `workspace/33-omp-run`, para o `frontier.sh`; `workspace/34-omp-plan`,
para o `stage.sh`.

### S2 — sessão headless do omp com `/skill:anvil-auto` (existente)

`omp -p --mode json` sobre projetos de fixture, em vários turnos quando há
entrada humana. Casos:

- largada: árvore suja recusada sem escrita; sem `## Comando de verificação`,
  recusa com o caminho; perfil de outro tracker, a mesma recusa dos condutores;
- entrada: depois das respostas do grill, o roteiro é escrito e mostrado, e nada é
  criado antes do sim; com o sim, o roteiro é commitado na `main` antes de
  qualquer branch;
- corrente de duas entradas, a segunda dependendo da primeira, num projeto sem PR
  e com um comando de verificação trivial: a primeira fecha com archive e merge
  local, o `Spec:` aparece na `main`, e a segunda nasce de um branch saído da
  `main` já com a primeira;
- spec parada: fixture com ticket travado já gravado e o comando de verificação
  saindo `1`. A spec fica aberta no branch, a dependente não começa, a
  independente segue, e o `report.md` na `main` diz onde parou e traz a pesquisa
  em `docs/specs/{id}/discovery/`;
- projeto que fecha por PR: archive, PR aberto, nenhum merge;
- a guarda bloqueando um merge indevido conta como recusa da guarda, não como
  sucesso do piloto;
- retomada: chamado no branch de uma spec aberta, o piloto continua do ponto que o
  disco indica.

**Limite.** Um P1 não se força de forma determinística, e a evidência nova da
pesquisa depende da web. O caso de travado parte de uma linha `Review:` já
gravada. Ele prova que o piloto lê o estado, pesquisa e registra; não prova que a
rodada extra é aberta. A rodada extra é aceita nas duas saídas: a linha no
`## Comments` citando o arquivo, ou o ticket em "o que ainda espera decisão".

Prior art: `workspace/33-omp-run`, `workspace/34-omp-plan` e
`workspace/35-omp-e2e`.

### S3 — `vendor-sync.sh verify` (existente)

A checagem da camada passa com o `anvil-auto` (nome igual ao diretório, trava de
invocação, caminhos citados que existem) e falha num fixture com a trava
ausente.

Prior art: `workspace/31-omp-verify`.

### Ponta a ponta, manual

Um projeto descartável em `workspace/` no omp, de `/skill:anvil-auto` até o
relatório, com um roteiro de duas entradas. As mudanças do bench, com a stack
plugada e no Claude Code, são verificadas só neste ponta a ponta: a entrevista, o
roteiro em português simples, o `gates.md` por spec e a parada no fim da
construção com o relatório de fechamento pendente.

## Out of Scope

- **Paralelo no piloto.** O piloto despacha em série. O `--parallel N` continua só
  na `anvil-run`.
- **Mais de uma spec construída ao mesmo tempo.** A corrente é spec por spec.
  Specs paradas ficam abertas em branches diferentes, mas o piloto nunca constrói
  duas de uma vez.
- **Branches empilhados para atravessar PR.** Descartados no ADR-0014.
- **Merge de PR pelo piloto.** Ele abre o PR e para.
- **Piloto no Claude Code ou no Codex.** Fora do omp, o fluxo segue manual, e o
  bench para no fim da construção.
- **Mudanças no `unlazy/`**, que é vendorizado: o formato do `gates.md` e os
  scripts do gate.
- **Trava em arquivo contra duas execuções simultâneas.**
- **Resolução automática de conflito de merge** fora do `docs/index.md`.
- **Mudanças na `anvil-plan`, na `anvil-run`, no `stage.sh` e no `frontier.sh`.**

## Further Notes

- **Desvio deliberado do caminho do relatório.** A decisão do grill dizia
  `docs/specs/{id}/report.md`, um caminho herdado do discovery, que tinha uma spec
  só. Esse caminho não se fecha com o relatório único da corrente nem com specs
  paradas em branches diferentes. Uma contradição que para a corrente antes de a
  spec nascer, por exemplo, não teria pasta onde ser registrada. O usuário
  escolheu `docs/specs/report.md`, na `main`, ao conferir os seams desta spec.
- **Três decisões fechadas ao conferir os seams**, que não estavam no grill: o
  `Spec:` commitado na `main` logo depois do `new-spec.sh`; o conflito de merge só
  no `docs/index.md` resolvido gerando o índice de novo; e a entrada pelo bench
  decidida pela rule da stack ou por `--bench`.
- **Consequência aceita no ADR-0014.** As decisões das últimas specs são tomadas
  antes de existir o código das primeiras, e só o relatório mostra o que o piloto
  adaptou. O critério de pronto de cada entrada é a régua que não se move.
- **O `Comando de verificação`** passa a ser contrato entre o `anvil-boot` e o
  piloto. Projetos que fizeram o boot antes desta spec, e que gravaram o comando
  com outro título, são recusados na largada com a instrução do que acrescentar.
