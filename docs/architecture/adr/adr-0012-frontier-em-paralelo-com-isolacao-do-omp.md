# ADR-0012 — O frontier roda em paralelo sob pedido, com a isolação do omp

- Status: aceito
- Data: 2026-09-25
- Revê em parte o [ADR-0011](./adr-0011-omp-como-harness-com-camada-propria.md): a
  alternativa "frontier em paralelo com worktree isolado" entra, sob pedido e só com
  a isolação do omp
- Origem: spec 004, ticket 09 (`docs/specs/004-extension-omp-layer-hardening/`)

## Contexto

O ADR-0011 pôs a `anvil-run` para despachar um `anvil-implementer` por ticket, em
série, e descartou o frontier em paralelo com worktree isolado por três motivos:
tickets *tracer bullet* se cruzam nos arquivos, `Status:` e `Review:` voltariam de
workspaces diferentes, e o merge por patch falha quando o texto não aplica. Ficou
para ser medido depois do modo em série.

A spec 004 ligou a isolação de tarefas do omp à `anvil-run`. Com
`task.isolation.enabled: true` e `task.isolation.merge: branch`, cada implementer
trabalha numa cópia isolada do checkout, commita num branch `omp/task/<id>`, e o
omp faz o cherry-pick desses commits no branch da spec. Os dois primeiros motivos
do ADR-0011 continuam valendo para tickets que se cruzam. O terceiro muda de forma:
o modo branch integra commits, não patch, e o que acontece quando o cherry-pick
conflita pode ser observado.

A documentação do omp 18.2.11 descrevia o modo branch sem dizer o que ele faz no
conflito. O ticket 09 conferiu na prática, com o omp 18.3.0, em duas sondas: dois
tickets numa chamada do `task`, os dois com `isolated: true`, cada implementer
mudando a mesma linha do mesmo arquivo. Na primeira, cada implementer fez um
commit só. Na segunda, três, como um implementer de verdade: um arquivo só dele,
depois a linha disputada, depois o ticket resolvido.

- O omp integra cada implementer quando ele termina, na ordem em que terminam, e
  não na ordem dos itens. O primeiro a terminar entrou inteiro no branch da spec.
- A integração do segundo conflitou. O resultado do `task` trouxe "Branch merge
  failed: omp/task/<id>" e "The unmerged branch remains for manual resolution". A
  árvore ficou limpa, sem `CHERRY_PICK_HEAD` e sem stash.
- Na segunda sonda, o primeiro commit do segundo implementer, o do arquivo só
  dele, ficou no branch da spec. O da linha disputada e o do ticket resolvido, não.
  O fonte (`src/task/worktree.ts`) explica: o omp faz o cherry-pick dos commits um
  por vez e, no conflito, só o `cherry-pick --abort` do commit que conflitou.
- Nas duas sondas, o ticket do segundo ficou com o `Status:` de antes no branch da
  spec, e o `frontier.sh` o devolveu no frontier. O trabalho inteiro dele ficou no
  `omp/task/<id>`.
- Lido no fonte do omp, não observado: o omp guarda a árvore suja com `git stash`
  antes do cherry-pick e a devolve depois. Só um conflito nessa devolução deixa a
  árvore suja, e o omp avisa. A `anvil-run` só despacha com a árvore limpa, por
  isso esse caso não foi reproduzido.

## Decisão

**O frontier roda em paralelo só sob pedido e só com a isolação no modo branch.**
A `anvil-run` aceita `--parallel N`, com N de 2 em diante. Com a linha
`isolation: on` do `frontier.sh`, cada despacho é uma leva: uma chamada do `task`
com até N itens, um por caminho da linha `frontier_files`, na ordem do script, todos
com `isolated: true`. Cada implementer faz o próprio review, como em série. Sem o
pedido, a execução segue em série.

**Fora do modo branch, o pedido é recusado.** Com `isolation: off`, dois
implementers dividiriam a árvore da spec. Com `isolation: misconfigured`, a
isolação está ligada no modo patch: o omp integra sem commit, e a leva misturaria
o trabalho de vários tickets fora de commit antes da parada. Nos dois casos, a
primeira linha de andamento recusa o paralelo com o motivo, e a execução segue em
série.

**O conflito não tem tratamento próprio.** Depois da leva, o script roda de novo,
e cada ticket passa pela comparação de antes e depois da 003. O ticket cujo
cherry-pick conflitou não muda de estado e sai como pulado nesta execução. O
relatório nomeia o branch `omp/task/<id>` dele e avisa que os commits anteriores
ao conflito já estão no branch da spec. A execução seguinte o despacha de novo,
sobre o branch da spec, que já tem o trabalho do ticket que entrou e esses
commits. Se a árvore ficar suja, a parada de sempre, o `halt`, pega.

**O relatório mede.** O `frontier.sh` emite `ready:`, com quantos tickets estão no
frontier, e a `anvil-run` põe no relatório o `ready` de cada rodada, para o
operador ver se o paralelo compensa.

## Alternativas descartadas

- **Paralelo sem isolação, ou com worktree gerido pelo anvil.** Dois implementers
  na mesma árvore commitariam o trabalho um do outro. Um worktree do anvil
  duplicaria o que o omp já faz, com a integração ainda por escrever.
- **Paralelo também em modo patch.** A leva terminaria com o trabalho de vários
  tickets fora de commit, misturado, e a saída da parada deixaria de ser um
  `git stash -u` ou um commit do operador por ticket.
- **Resolver o conflito na integração, por modelo ou por ferramenta.** O ticket
  pulado roda de novo sobre o branch que já tem o trabalho do outro. Resolver
  conflito automaticamente é outra decisão, fora da spec 004.
- **A `anvil-run` achar os caminhos da leva pelo nome dos arquivos.** A linha
  `ticket` não traz o arquivo, e o supervisor não lê a pasta de tickets. A chave
  `frontier_files` entrega os caminhos na ordem do script.

## Consequências

**A favor.** Tickets independentes deixam de esperar um pelo outro quando o
operador pede, sem mudar nada para quem não pede. O conflito cai num caminho que
já existia, o do ticket pulado, e a árvore da spec fica limpa. O `ready` por rodada
diz quanto paralelo havia para aproveitar.

**Contra.** Tickets que se cruzam nos arquivos conflitam, e o segundo espera a
próxima execução: numa spec de *tracer bullets* encadeados, o paralelo rende pouco,
e o `ready` mostra isso. Do ticket que conflitou, os commits anteriores ao
conflito ficam no branch da spec sem o ticket resolvido, e o implementer seguinte
parte deles; reaplicar o `omp/task/<id>` à mão os duplicaria. O branch fica no
repositório com o trabalho inteiro, e os commits da leva entram no branch da spec
na ordem em que os implementers terminam. O `sha` que o implementer grava na linha
`Review:` é o do workspace isolado, e o cherry-pick pode trocá-lo, como o ticket 08
registrou.
