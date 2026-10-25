---
name: anvil-run
description: Implementa uma spec do anvil ticket a ticket, no omp. A sessão vira supervisor, lê o frontier do disco, despacha um anvil-implementer por ticket, em série ou, sob pedido e com isolação, em levas, e termina com um relatório e o próximo passo.
argument-hint: "número da spec, opcional; sem ele, o do branch atual. --parallel N, opcional: até N tickets ao mesmo tempo, com isolação"
disable-model-invocation: true
---

# Supervisor da spec

O operador chamou esta skill para ver a spec implementada sem abrir uma sessão por
ticket. Você é o supervisor. Quem implementa é o agente `anvil-implementer`, um por
ticket, cada um num contexto novo. Você não edita arquivo, não commita e não mexe
em ticket. O estado é o disco, e não esta conversa nem o que o implementer disse.

Os argumentos, se vieram, são o número da spec e o pedido de paralelo,
`--parallel N`. Não pergunte nada ao operador durante a execução.

## Isolação

O modo da execução vem da linha `isolation` do script, e não de você: o script lê a
configuração do omp com `omp config get` e escreve o resultado. Use a linha da
primeira rodada do script, e o modo vale para a execução inteira:

- `isolation: on`: com isolação. Todo despacho sai com `isolated: true`, o
  implementer trabalha numa cópia isolada do checkout, e o omp traz os commits dele
  para o branch da spec;
- `isolation: off`: sem isolação. O item não leva `isolated`, e o implementer
  trabalha na árvore da spec, como na 003;
- `isolation: misconfigured`: a isolação está ligada, mas fora do modo branch, e o
  omp vai integrar o trabalho sem commit. Antes do primeiro despacho, diga isso ao
  operador e aponte a configuração do omp, que precisa de
  `task.isolation.merge: branch`, como o `/skill:anvil-omp` explica. O aviso não é
  uma parada: na mesma mensagem, despache como em `on`, com `isolated: true`. A
  árvore suja que o omp deixa para o laço no `halt`.

O laço é o mesmo nos três.

## Paralelo

Sem `--parallel N`, a execução é em série: cada despacho leva um ticket.

Com `--parallel N`, N de 2 em diante, e `isolation: on`, cada despacho é uma leva
de até N tickets do frontier numa chamada só do `task`, como o passo 4 do laço
diz. Cada implementer trabalha na cópia isolada dele e faz o próprio review, como
em série.

Nos outros casos, recuse o paralelo na primeira linha de andamento, com o motivo,
e siga em série:

- `isolation: off`: sem isolação, dois implementers dividiriam a árvore da spec;
- `isolation: misconfigured`: fora do modo branch, o omp integra sem commit, e a
  leva misturaria o trabalho de vários tickets fora de commit;
- N menor que 2, ou que não é um número.

## Ler o estado

O script é o `~/.omp/agent/skills/anvil-run/frontier.sh`, da instalação de
usuário. No diretório em que a sessão está, que é a raiz do projeto, rode sem `cd`:

```bash
bash ~/.omp/agent/skills/anvil-run/frontier.sh [NNN] [--skip "NN NN"] [--resume NN]
```

Passe o número da spec se o operador passou. `--skip` leva os tickets que você anotou
como pulados nesta execução, explicados abaixo. `--resume NN` só vai na leitura
que segue um despacho interrompido do NN, como o passo 5 diz. O script sai com `refusal:` quando
não há o que conduzir daqui, como no branch de outra spec, num branch sem número ou
num projeto sem o perfil `docs/specs` do tracker.
Nesse caso, mostre a linha ao operador e pare. Não troque de branch nem rode o
script com outro número: a recusa é a resposta, e o branch é escolha do operador.

Fora a recusa, o script devolve a linha `isolation`, lida acima, a linha `screen`,
`yes` ou `no` com o motivo, e, sem `ui/` e com tudo resolvido, uma linha `story`
por user story da `spec.md`. Depois vêm uma linha por ticket, com `status`,
`reviews`, `last`, `blocked_by` e `class`, e `frontier`, `ready`, com quantos
tickets estão no frontier, `frontier_files`, com os caminhos deles na mesma ordem,
`skipped`, `locked`, uma linha `open_p1` por P1 de travado, `depend_on_locked`,
`all_resolved`, às vezes `halt`, e `next`. O frontier já exclui o ticket travado,
cuja última `Review:` tem `round` 2 ou mais e `verdict=fail`, e o de bloqueio
ilegível, `class=unreadable_blockers`, cujo `Blocked by` não é uma lista de
números: nele, `blocked_by` traz entre aspas o texto da linha como está no
arquivo. Com a árvore suja, o script devolve `halt` e `next: none`, salvo com
`--resume NN` e o NN despachável: aí devolve `resume: NN` e o NN como `next`.
Resolvido, travado, pulado ou com bloqueio ilegível ou pendente não recebe essa
exceção. Sem ela, um implementer novo commitaria o que sobrou junto com outro
ticket, e o próximo passo de uma spec resolvida partiria do que está fora de commit.

## O laço

1. Rode o script.
2. Se `next` é `none`, vá para o fim. É a única condição de parada do laço, e
   quem a decide é o script.
3. Anote o valor da linha `ready` desta rodada, para o relatório: só a leitura que
   vem antes de um despacho conta, inclusive de retomada, e a releitura do passo 6 não. Mostre ao
   operador uma linha de andamento: os tickets que vão sair e quantos já estão
   resolvidos.
4. Despache com o `task`, numa chamada só. Em série, ela tem um item, o `next`.
   Numa leva, um item por caminho da linha `frontier_files`, na ordem dela, até N
   itens; o primeiro é o `next`. Em cada item, `agent` é `anvil-implementer` e o
   `task` é o caminho do ticket. Com `isolation: on` ou `misconfigured`, todo item
   leva também `isolated: true`. No `context`, diga a pasta da spec e o branch e
   peça resposta em pt-BR. Antes do primeiro despacho de cada ticket, anote o
   `HEAD` e guarde-o até o fim da execução. O implementer é bloqueante, e a
   chamada só volta quando todos os itens terminam. Não espere pelo `hub`, não
   chame outra ferramenta na mesma mensagem e nunca faça duas chamadas do `task`
   ao mesmo tempo. Fora de `isolation: on`, nunca despache dois tickets ao mesmo
   tempo, como a seção Paralelo diz. Não leia o ticket, não investigue e não
   termine o trabalho dele: a única intervenção permitida é retomar o despacho
   pelo passo 5, sem implementar nem commitar no lugar dele.
5. Reconheça o **despacho interrompido** antes de comparar o estado: resultado do
   `task` sem os três campos `ticket`, `status` e `review`, cancelado ou com erro.
   Para cada ticket interrompido, rode o script com `--resume NN` na leitura
   seguinte, mantendo os `--skip` acumulados. O disco continua soberano: com
   `halt`, ou com o NN já resolvido, travado, pulado ou fora do frontier, não
   retome; siga ao passo 6 com essa saída.

   O limite é de **duas retomadas do despacho por ticket nesta execução**,
   contando as duas formas abaixo. Antes de cada tentativa, incremente o
   contador e escreva esta linha de andamento, preenchendo ticket e tentativa:
   `ticket <NN> — retomada do despacho, tentativa <1 ou 2>/2`.
   - Primeiro tente o agente vivo: um id no resultado não basta. Resultado
     `completed` indica agente encerrado, não vivo. Se o retorno cancelado ou com
     erro não diz se ele ainda roda, consulte `read agent://<id>`; só o estado
     ainda em execução autoriza a tentativa pelo agente vivo. Mande por
     `write agent://<id>` que termine o ticket e devolva os três campos e espere
     com `wait`. Não abra outro implementer enquanto esse agente estiver vivo.
     Com os campos e sem erro ou cancelamento, o despacho terminou; vá ao passo 6.
     Se continuar interrompido, repita este passo, inclusive a leitura com
     `--resume NN`, sem zerar o contador.
   - Sem agente vivo e com `isolation: off`, despache um `anvil-implementer` novo
     para o mesmo ticket, pelo passo 4. No `context`, escreva **retomada do
     despacho**, o `HEAD` de antes do primeiro despacho, e que ele deve continuar
     dos commits desde esse `HEAD` e da árvore suja, preservando ambos. Anote o
     `ready` e mostre o andamento como no passo 3. Ao voltar, repita este passo,
     sem trocar o `HEAD` inicial nem zerar o contador.
   - Sem agente vivo e com isolação (`on` ou `misconfigured`), ou sem tentativa
     restante, anote o ticket como pulado, com o motivo: cópia isolada que não
     volta, ou limite de duas retomadas do despacho. Rode o script já com ele no
     `--skip`, sem `--resume` para esse ticket, e siga ao passo 6. Mesmo com
     `halt` pela sujeira, o relatório inclui esse pulado e seu motivo.

   Só o despacho interrompido passa por essa exceção ao não redespachar; ele
   ainda não é pulado enquanto cabe uma retomada. Resultado com os três campos,
   sem cancelamento nem erro, segue a comparação do passo 6, inclusive quando
   diz que falhou, que faltou ferramenta ou que o omp não integrou o trabalho.
6. Rode o script de novo, salvo a saída que o passo 5 já trouxe para um pulado ou
   um impedimento do disco, e compare cada ticket com a leitura anterior ao seu
   primeiro despacho. Se `status`, `reviews` e `last` estão iguais, anote-o como
   pulado, e rode o script já com ele no `--skip`. Toda chamada leva todos os
   pulados acumulados. Nunca despache um pulado de novo nesta execução: quem
   tenta de novo é a próxima execução; a retomada do despacho no passo 5 acontece
   antes de anotá-lo como pulado.
7. Mostre a linha de andamento de cada ticket despachado, com o `status` e a
   `last` lidos do disco. Volte ao passo 2 com a última saída do script.

## O fim

Sem `halt`, o relatório abre com uma linha que diz o modo da execução, lido da
linha `isolation`: `modo: com isolação` com `on`, `modo: sem isolação` com `off`,
e, com `misconfigured`, `modo: com isolação, fora do modo branch`, seguido da
configuração que falta, `task.isolation.merge: branch`.

Com `halt`, a primeira linha do relatório é o texto da linha `halt`, depois de
`halt: `, copiado como está: ele já diz o modo, a configuração que falta e como
sair. Depois, mostre o `git status --short`. A saída é do operador: você não
roda `git stash`, não commita e não limpa a árvore, porque o que sobrou pode ser
do operador ou de um implementer que caiu. Depois, siga com o resto do relatório.

Todo relatório, com `halt` ou sem, traz a medição: os valores de `ready` que você
anotou no passo 3, um por rodada, na ordem, como `ready por rodada: 3, 2, 1`. Sem
nenhum despacho, `ready por rodada: nenhuma`.

Com `all_resolved: yes` e `halt`, o relatório lista os tickets resolvidos nesta
execução e, no lugar do próximo passo, diz o que a linha `halt` diz: a execução
seguinte, com a árvore limpa, recomenda o próximo passo. O relatório não diz qual
é, nem como passo para depois da parada.

Com `all_resolved: yes` sem `halt`, o relatório lista os tickets resolvidos nesta
execução e termina invocando o `anvil-next` — leia `skill://anvil-next` e siga-o —,
com o foco na rota que a linha `screen` decide. Escreva a rota no foco como ela se
chama no omp, por `/skill:`, para o prompt sair pronto para colar. A invocação
acontece só aqui, no relatório final, nunca entre despachos, e você não executa a
rota:

1. `screen: yes`: o foco é `/skill:anvil-browser-qa`, com o motivo que a linha dá.
2. `screen: no`: leia as linhas `story`. Se uma delas descreve algo que abre no
   navegador com palavras que o script não reconhece, como um gráfico que o usuário
   filtra, um mapa clicável ou cards que se arrastam entre colunas, o foco é
   `/skill:anvil-browser-qa`, citando essa história.
   Saída de terminal, stdout, stderr, código de saída, arquivo, log e API não são
   tela, porque o browser QA precisa de algo que abra no navegador. Senão, o foco é
   `/skill:anvil-docs archive`.

Nunca troque um `screen: yes` por archive: a falta de `ui/` não conta contra, porque
a pasta só existe quando alguém a escreveu.

Com pendência, o relatório não recomenda próximo passo, nem archive nem browser
QA: a spec ainda não terminou. Ele lista:

- os resolvidos nesta execução;
- os travados, cada um com o texto das linhas `open_p1` dele, por extenso. A
  terceira rodada é escolha do operador;
- os que dependem de um travado, da linha `depend_on_locked`;
- os de bloqueio ilegível, `class=unreadable_blockers`, cada um com o texto do
  `blocked_by`. O operador corrige a linha para uma lista de números, como `01, 02`,
  e roda a skill de novo;
- os pulados, que terminaram sem mudar o estado ou cujo despacho interrompido
  ficou sem agente vivo com isolação ou passou do limite de duas retomadas, com
  o motivo. Rodar a skill de novo tenta de novo. O pulado cujo trabalho o omp não integrou,
  com "Branch merge failed" no resultado do `task`, leva também o nome do branch
  `omp/task/<id>` e, se houver, o aviso de que os commits dele anteriores ao
  conflito já estão no branch da spec;
- os que ainda esperam por outro ticket, com a lista da `class` deles.

Com pendência ou com `halt`, você não invoca o `anvil-next` com foco: a cauda de
roteamento das diretivas o invoca sem argumento, depois do relatório.

## Nunca

- Abrir a terceira rodada do review, nem pedir ao implementer que a abra.
- Rodar browser QA ou archive, abrir PR, fazer merge ou push.
- Implementar, editar ticket ou código, ou commitar no lugar do implementer.
- Guardar, commitar ou descartar o que está fora de commit: `git stash`,
  `git commit`, `git checkout`, `git restore`, `git reset` ou `git clean`.
- Trocar de branch, criar branch ou rodar o script em outro repositório.
- Recomendar o próximo passo da spec com `halt`.
- Chamar o `task` para outra coisa que não despachar o `next`, a leva ou a
  retomada do despacho autorizada no passo 5, a `anvil-implementer`.

## Retomada

Se a sessão cair, rodar a skill de novo retoma pelo disco: o script recalcula o
frontier a partir dos tickets gravados. A lista de pulados vale só para a execução
que a anotou.

Isso é **retomada da skill**, numa execução nova. A **retomada do despacho** do
passo 5 acontece dentro da mesma execução, conserva o `HEAD` anterior ao primeiro
despacho e tem no máximo duas tentativas por ticket, pelo agente vivo ou por um
implementer novo sem isolação. Ela não transfere a implementação ao supervisor.

Sem isolação, se a sessão inteira caiu, a execução nova não tem a atribuição da
sujeira ao despacho interrompido: o script para com `halt` até o operador decidir.
Com isolação e sem agente vivo, o que ele deixou não chega ao branch da spec: o
ticket fica pulado nesta execução, e a seguinte o despacha de novo.

Numa leva, o omp integra cada implementer quando ele termina, com o cherry-pick dos
commits dele, um por vez. Se um commit conflita, o omp desfaz só esse e para ali:
os commits anteriores do ticket, se houver, já estão no branch da spec, e o
trabalho inteiro fica no branch `omp/task/<id>`. O ticket não muda de estado e sai
como pulado, e a execução seguinte o despacha sobre o que já entrou. Se a árvore
ficar suja, o script para com `halt`.
