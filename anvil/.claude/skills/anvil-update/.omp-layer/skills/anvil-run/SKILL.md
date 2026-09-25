---
name: anvil-run
description: Implementa uma spec do anvil ticket a ticket, no omp. A sessão vira supervisor, lê o frontier do disco, despacha um anvil-implementer por ticket, em série, e termina com um relatório e o próximo passo.
argument-hint: "número da spec, opcional; sem ele, o do branch atual"
disable-model-invocation: true
---

# Supervisor da spec

O operador chamou esta skill para ver a spec implementada sem abrir uma sessão por
ticket. Você é o supervisor. Quem implementa é o agente `anvil-implementer`, um por
ticket, cada um num contexto novo. Você não edita arquivo, não commita e não mexe
em ticket. O estado é o disco, e não esta conversa nem o que o implementer disse.

O argumento, se veio, é o número da spec. Não pergunte nada ao operador durante a
execução.

## Isolação

A primeira coisa que você escreve nesta execução, antes de rodar o script, é a linha
`task aceita: <propriedades>`, com as propriedades que um item de `tasks` aceita,
copiadas da definição do tool `task` que você recebeu, como `agent`, `task`, `name`
e as outras. Você já tem essa definição: ela não se consulta por ferramenta nem por
subagente.

O omp só põe `isolated` nessa definição quando a isolação de tarefas está ligada na
configuração dele. Por isso a propriedade basta, e não há outra coisa a conferir:

- `isolated` está na linha: escreva `modo: com isolação`. Todo despacho sai com
  `isolated: true`, o implementer trabalha numa cópia isolada do checkout, e o omp
  traz os commits dele para o branch da spec;
- `isolated` não está na linha: escreva `modo: sem isolação`. O item não leva
  `isolated`, e o implementer trabalha na árvore da spec.

O modo vale para a execução inteira, e o laço é o mesmo nos dois.

## Ler o estado

O script é o `.omp/skills/anvil-run/frontier.sh`. No diretório em que a sessão
está, que é a raiz do projeto, rode sem `cd`:

```bash
bash .omp/skills/anvil-run/frontier.sh [NNN] [--skip "NN NN"]
```

Passe o número da spec se o operador passou. `--skip` leva os tickets que você anotou
como pulados nesta execução, explicados abaixo. O script sai com `refusal:` quando
não há o que conduzir daqui, como no branch de outra spec, num branch sem número ou
num projeto sem o perfil `docs/specs` do tracker.
Nesse caso, mostre a linha ao operador e pare. Não troque de branch nem rode o
script com outro número: a recusa é a resposta, e o branch é escolha do operador.

Fora a recusa, o script devolve a linha `screen`, `yes` ou `no` com o motivo, e, sem
`ui/` e com tudo resolvido, uma linha `story` por user story da `spec.md`. Depois
vêm uma linha por ticket, com `status`, `reviews`, `last`, `blocked_by` e `class`, e
`frontier`, `skipped`, `locked`, uma linha `open_p1` por P1 de travado,
`depend_on_locked`, `all_resolved`, às
vezes `halt`, e `next`. O frontier já exclui o ticket travado, cuja última
`Review:` tem `round` 2 ou mais e `verdict=fail`, e o de bloqueio ilegível,
`class=unreadable_blockers`, cujo `Blocked by` não é uma lista de números: nele,
`blocked_by` traz entre aspas o texto da linha como está no arquivo. Com a árvore
suja, o script devolve `halt` e `next: none`, porque um implementer novo commitaria
o que sobrou junto com o ticket dele.

## O laço

1. Rode o script.
2. Se `next` é `none`, vá para o fim. É a única condição de parada do laço, e
   quem a decide é o script.
3. Mostre ao operador uma linha de andamento: o ticket que vai sair e quantos já
   estão resolvidos.
4. Despache o `next` com o `task`, numa chamada com um item só: `agent` é
   `anvil-implementer` e o `task` é o caminho do ticket. Com `modo: com isolação`,
   o item leva também `isolated: true`, em todo despacho. No `context`, diga a pasta
   da spec e o branch. O implementer é bloqueante, e a chamada só volta quando ele
   termina. Não espere pelo `hub`, não chame outra ferramenta na mesma mensagem e
   nunca despache dois tickets ao mesmo tempo.
   O que o implementer devolve não muda o laço, nem quando ele diz que falhou ou
   que faltou ferramenta. Não leia o ticket, não investigue e não termine o trabalho
   dele: quem decide o que vem depois é o disco, no passo 5.
5. Rode o script de novo e compare a linha do ticket despachado com a de antes.
   Se `status`, `reviews` e `last` estão iguais, o implementer terminou sem
   mudar o estado. Anote o ticket como pulado, na memória desta execução, e rode o
   script mais uma vez, já com ele no `--skip`. Daqui em diante, toda chamada leva
   o `--skip` com todos os pulados. Nunca despache um pulado de novo nesta
   execução, nem quando o implementer caiu, abortou ou devolveu erro: quem tenta de
   novo é a próxima execução.
6. Mostre a linha de andamento do ticket, com o `status` e a `last` lidos do
   disco. Volte ao passo 2 com a última saída do script.

## O fim

O relatório abre com uma linha que diz o modo da execução: com isolação ou sem
isolação.

Com `halt`, o relatório segue por ela: mostre o `git status --short` e diga como
sair, como a linha diz. A saída é do operador: ele guarda o que sobrou com
`git stash -u`, ou faz um commit dele, e roda a skill de novo. Você não sai da
parada: não rode `git stash`, não commite e não limpe a árvore. O que sobrou pode
ser do operador ou de um implementer que caiu. Com `modo: com isolação`, um `halt`
que aparece depois de um despacho sempre vem do omp, porque o script só despacha
com a árvore limpa: o omp integrou o trabalho sem commit, e a isolação está no
modo patch. Diga isso e aponte a configuração do omp, que precisa de
`task.isolation.merge: branch`, como o `/skill:anvil-omp` explica. Depois, siga
com o resto do relatório.

Com `all_resolved: yes`, o relatório lista os tickets resolvidos nesta execução e
recomenda o próximo passo, sem executá-lo, escrito como está aqui, porque no omp
skill se chama por `/skill:`. A linha `screen` decide:

1. `screen: yes`: recomende `/skill:anvil-browser-qa` e diga o motivo que a linha dá.
2. `screen: no`: leia as linhas `story`. Se uma delas descreve algo que abre no
   navegador com palavras que o script não reconhece, como um gráfico que o usuário
   filtra, um mapa clicável ou cards que se arrastam entre colunas, recomende
   `/skill:anvil-browser-qa` e cite essa história.
   Saída de terminal, stdout, stderr, código de saída, arquivo, log e API não são
   tela, porque o browser QA precisa de algo que abra no navegador. Senão,
   recomende `/skill:anvil-docs archive`.

Nunca troque um `screen: yes` por archive: a falta de `ui/` não conta contra, porque
a pasta só existe quando alguém a escreveu.

Com pendência, o relatório lista:

- os resolvidos nesta execução;
- os travados, cada um com o texto das linhas `open_p1` dele, por extenso. A
  terceira rodada é escolha do operador;
- os que dependem de um travado, da linha `depend_on_locked`;
- os de bloqueio ilegível, `class=unreadable_blockers`, cada um com o texto do
  `blocked_by`. O operador corrige a linha para uma lista de números, como `01, 02`,
  e roda a skill de novo;
- os pulados, que terminaram sem mudar o estado, e o motivo que o implementer deu.
  Rodar a skill de novo tenta de novo;
- os que ainda esperam por outro ticket, com a lista da `class` deles.

## Nunca

- Abrir a terceira rodada do review, nem pedir ao implementer que a abra.
- Rodar browser QA ou archive, abrir PR, fazer merge ou push.
- Implementar, editar ticket ou código, ou commitar no lugar do implementer.
- Guardar, commitar ou descartar o que está fora de commit: `git stash`,
  `git commit`, `git checkout`, `git restore`, `git reset` ou `git clean`.
- Trocar de branch, criar branch ou rodar o script em outro repositório.
- Chamar o `task` para outra coisa que não despachar o `next` a um
  `anvil-implementer`.

## Retomada

Se a sessão cair, rodar a skill de novo retoma pelo disco: o script recalcula o
frontier a partir dos tickets gravados. A lista de pulados vale só para a execução
que a anotou.

Sem isolação, um implementer que caiu deixa a árvore suja, e o script para com
`halt` até o operador decidir. Com isolação, o que ele deixou não chega ao branch da
spec: o ticket fica com o estado de antes, sai como pulado nesta execução, e a
seguinte o despacha de novo.
