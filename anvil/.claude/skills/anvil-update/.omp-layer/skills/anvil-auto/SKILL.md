---
name: anvil-auto
description: Piloto automático do anvil no omp. Recusa a largada indevida, conduz o grill sobre o plano inteiro de várias specs, escreve o roteiro em docs/specs/roadmap.md e o commita na main com o único sim do operador. Depois, sem pausa, leva cada entrada do roteiro da spec ao merge local, com relatório em docs/specs/report.md.
argument-hint: "o pedido, que vai para o grill"
disable-model-invocation: true
---

# Piloto automático

O operador chamou esta skill com um pedido que pode ocupar várias specs. Você é o
piloto. Ele participa uma vez só: no grill, que cobre o plano inteiro e termina no
**roteiro** escrito em `docs/specs/roadmap.md`. A confirmação dele sobre o roteiro
escrito é o único sim da execução. Depois do sim, você conduz a **corrente** sem
pausa: cada entrada do roteiro vira uma spec, que vai da spec ao merge local, e a
execução termina oferecendo um grill novo. Carregar uma skill é lê-la com o `read`
em `skill://<nome>` e segui-la.

O argumento, se veio, é o pedido.

## Largada

Comece sempre por aqui, antes de dizer qualquer coisa ao operador e antes de
escrever qualquer arquivo. Confira, nesta ordem, no diretório em que a sessão está,
que é a raiz do projeto, e rode tudo sem `cd`. A primeira recusa encerra a vez:
mostre o motivo, diga como sair dela e pare. Numa recusa, não carregue o grill, não
escreva, não commite e não se ofereça para fazer o trabalho por conta própria.

1. **Perfil do tracker.** Rode o script do planejamento, da instalação de usuário:

   ```bash
   bash ~/.omp/agent/skills/anvil-plan/stage.sh
   ```

   Com `next: refused`, a recusa é a linha `reason`, copiada como está: é o mesmo
   texto da `anvil-plan` e da `anvil-run`. Senão, guarde as linhas `branch`, `spec`
   e `next` para o passo 4.

2. **Árvore limpa.** Rode `git status --porcelain`. Com qualquer linha na saída,
   recuse: o piloto commita na `main`, e o que está fora de commit entraria num
   commit dele. Mostre o `git status --short` e diga que o operador commita ou
   guarda o que é dele e chama o piloto de novo. A árvore é do operador: você não
   roda `git stash`, `git commit`, `git checkout`, `git restore`, `git reset` nem
   `git clean`.

3. **Comando de verificação.** Rode:

   ```bash
   awk '$0 == "## Comando de verificação" {s=1; next} s && /^## /{exit} s && /^```bash$/{b=1; next} b && /^```$/{exit} b' .claude/rules/anvil.md
   ```

   Saída vazia, ou erro porque o arquivo não existe, é recusa: o piloto só fecha uma
   spec com o comando de verificação do projeto rodado por ele saindo `0`, e sem
   comando nenhuma spec fecha. A mensagem diz onde e como declarar: em
   `.claude/rules/anvil.md`, uma seção com o título exato
   `## Comando de verificação` e, nela, um bloco `bash` com o comando que roda a
   verificação do projeto na raiz e sai `0` quando passa, assim:

   ````markdown
   ## Comando de verificação

   ```bash
   npm test
   ```
   ````

   Diga também que projeto novo ganha essa seção pelo `/anvil-boot`, e que o
   piloto é chamado de novo depois de ela existir.

4. **Branch.** Pela saída do passo 1. Com `branch: main`, siga para a entrada. Em
   qualquer outro branch, recuse e aponte a `main`: o piloto começa nela, e trocar
   de branch é escolha do operador. Diga o que o branch é:
   - com `next: none`, o branch de uma spec arquivada, a da linha `spec`;
   - com `spec: none`, um branch sem spec, pelo motivo da linha `reason`;
   - nos outros casos, o branch da spec aberta da linha `spec`.

## Entrada

Na `main`, a entrada é o `anvil-grill`, com o pedido como ponto de partida. Sem
pedido no argumento e sem nada do plano nesta conversa, peça o pedido e pare.

### O roteiro que já existe

Antes de carregar o grill, rode o script do roteiro, da instalação de usuário:

```bash
bash ~/.claude/skills/anvil-docs/scripts/roadmap.sh
```

Com `roadmap: none`, não há roteiro, e o grill parte só do pedido. Senão, leia
`docs/specs/roadmap.md` e anote as entradas **inacabadas**: as das linhas `entry:`
com `state` diferente de `closed`. Se a saída é uma recusa, sem linhas `entry:`,
toda seção `## ` do arquivo conta como inacabada.

Havendo inacabada, o grill parte desse roteiro e o edita com o pedido: acrescenta,
reordena ou abandona entradas. Na primeira rodada, diga ao operador que o roteiro
existe e quais entradas estão inacabadas, com o estado de cada uma.

Abandonar uma entrada é tirá-la do arquivo, e o histórico fica no git. Só o
operador abandona, e uma entrada por vez: vale a resposta dele a uma pergunta do
grill que nomeia a entrada e pergunta se ela sai do roteiro. Um pedido de roteiro
novo, ou de esquecer o plano anterior, não abandona nenhuma entrada sozinho. A
entrada que fica guarda o nome e a linha `Spec:`, se tiver: o nome é o branch da
spec, e o `Spec:` liga a entrada à pasta dela.

### Anexo

Um arquivo que o operador passa de fora do repositório, como um PDF, uma planilha
ou um documento, entra em `docs/discovery/` antes de ser usado. Arquivo de texto,
como `.md`, `.txt` ou `.csv`, é copiado como está. Arquivo que não é texto tem o
texto extraído para `docs/discovery/<nome>.md`, que abre com uma linha dizendo de
onde veio. Daí em diante, leia e cite a cópia em `docs/discovery/`, e nunca o
caminho de fora. Nenhuma pergunta nem decisão do grill sai do anexo antes disso.

### O grill

Carregue o `anvil-grill` com o pedido e, havendo, o roteiro que já existe. Siga a
skill como ela é, com as rodadas, as recomendações, os ADRs e o glossário. A árvore
de decisões cobre o plano inteiro: as specs, a ordem, o que fica de fora do plano
e, para cada entrada:

- o **nome**, em kebab-case e único, que vira o `--short-name` do `new-spec.sh` e
  o nome do branch da spec;
- o `Tipo:`, um dos tipos do `new-spec.sh`: `feature`, `fix`, `hotfix`, `gmud`,
  `refactor`, `experimental` ou `extension`;
- o `Depende de:`, com os nomes das entradas que precisam fechar antes;
- o `Entra:` e o `Fica de fora:`, o escopo;
- o `Pronto quando:`, um critério que se observa.

Quando o frontier do grill esvazia, não peça a confirmação do entendimento em
abstrato. Escreva o roteiro e peça a confirmação sobre ele, como dizem as seções
seguintes. Essa é a confirmação que fecha o grill.

### Escrever e validar

Escreva `docs/specs/roadmap.md` inteiro, neste formato. Cada entrada é uma seção de
segundo nível com o nome, e as chaves são linhas `Chave: valor` no começo da linha.
A ordem das seções é a ordem do roteiro. O arquivo não tem `Status:`, e você não
escreve `Spec:` em entrada nova.

```markdown
# Roteiro

## cadastro-de-clientes

Tipo: feature
Depende de:

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

Depois de escrever, rode o `roadmap.sh` de novo e confira, na ordem:

1. Uma linha `refusal:` é uma recusa do roteiro. Não o mostre para confirmação:
   volte ao grill com o motivo, numa rodada com a pergunta que o resolve, como qual
   das duas entradas de um ciclo depende da outra. Com a resposta, corrija o arquivo
   e valide de novo.
2. Cada inacabada anotada antes do grill está numa linha `entry:`, ou o operador a
   abandonou de forma explícita. Faltando alguma, o roteiro substitui o anterior e
   está recusado: não o mostre. Volte ao grill com uma pergunta por entrada que
   falta, pelo nome: ela fica ou sai do roteiro?

### Mostrar e confirmar

Só o roteiro que passou nas duas conferências é mostrado. Leia o arquivo do disco e
mostre-o inteiro, como está escrito, e termine a vez perguntando se este é o
roteiro que o piloto vai executar. A pergunta é a última coisa da vez. A resposta
decide:

- sim: siga para a seção seguinte;
- uma correção ou uma pergunta: responda e volte ao grill no ponto que ela abriu.
  Depois, escreva, valide e mostre de novo, com a mesma pergunta;
- não, sem correção: pare sem commitar. O que foi escrito fica na árvore, e o
  destino dele é escolha do operador.

### Com o sim

Commite na `main`, num commit só, tudo o que a entrada escreveu: o roteiro, as
cópias de anexo em `docs/discovery/`, e os ADRs e o glossário do grill. A árvore
estava limpa na largada, então tudo o que está fora de commit veio da entrada:

```bash
git add -A
git commit -m "docs(roadmap): record the roadmap confirmed by the operator"
```

Se a entrada não mudou nenhum arquivo, não há o que commitar: o roteiro
confirmado já está na `main`. Anote o commit da `main` com
`git rev-parse --short HEAD`, para o relatório, e siga para a corrente na mesma
vez, sem esperar resposta.

## Corrente

Do sim ao fim, conduza sem pausa: não pergunte nada ao operador e não termine a
vez entre uma spec e outra. O estado é o disco, relido a cada passo, e não esta
conversa. Dentro desta execução, quem decide o próximo passo é você: quando uma
skill de etapa termina, siga a corrente, sem ler o `anvil-next`.

Guarde na conversa, para o relatório, o que cada spec deixar: as pausas que você
respondeu e a saída do comando de verificação.

O laço, a partir da `main`:

1. Rode o `roadmap.sh`. Com `next: none`, vá para o fim. Senão, a entrada desta
   volta é a da linha `next`: leia a seção dela no `roadmap.md`.
2. Abra a spec.
3. Escreva a spec e os tickets.
4. Despache os tickets.
5. Confira o `PASS`.
6. Feche a spec.
7. Escreva o relatório na `main`, commite e volte ao passo 1.

Qualquer passo que não sai como as seções abaixo descrevem para a corrente, como a
seção "Fora do caminho feliz" diz.

### Abrir a spec

Na `main`, rode o script de spec nova, da instalação de usuário, com o `Tipo:` e o
nome da entrada:

```bash
bash ~/.claude/skills/anvil-to-spec/scripts/new-spec.sh --type <Tipo> --short-name <nome> --json
```

O JSON da saída dá o número, em `number`, e o branch, em `branch`, e vale sobre
qualquer previsão. O script deixa o checkout no branch novo, ainda sem commit.
Então, nesta ordem:

1. Volte à `main` com `git checkout main`.
2. No `roadmap.md`, acrescente a linha `Spec: <number>` à seção da entrada, junto
   das outras chaves: logo abaixo de `Depende de:` ou, sem ela, de `Tipo:`. É a
   única mudança no roteiro.
3. Commite só o roteiro:

   ```bash
   git add docs/specs/roadmap.md
   git commit -m "docs(roadmap): record spec <number> for <nome>"
   ```

4. Leve o branch da spec até esse commit e volte a ele:

   ```bash
   git checkout -B <branch> main
   ```

   O branch acabou de nascer e não tem commit próprio, então o `-B` só o avança.
   Assim o `Spec:` está na `main` antes de qualquer commit da spec, e o branch o
   contém.

### Spec e tickets

No branch da spec, carregue o `anvil-to-spec` com a entrada do roteiro como
contexto: o `Entra:` e o `Fica de fora:` são o escopo da spec, o `Pronto quando:`
é o critério de pronto dela, e o que o grill decidiu sobre a entrada também vale.
A spec cita o `Pronto quando:` como está, com os nomes de comando, arquivo ou tela
que ele traz, mesmo onde a skill evita caminho de arquivo: é por ele que a entrada
se mede, e um nome que some da spec some dos tickets. A skill publica na pasta do
branch, como o perfil do tracker manda para quem já está num branch de spec. Com a
spec escrita, commite no branch:

```bash
git add -A
git commit -m "docs(spec): add spec <number>"
```

Depois carregue o `anvil-to-tickets` sobre a spec, com o `Pronto quando:` como
critério de aceite de algum ticket, e commite os tickets do mesmo jeito, com
`docs(spec): add the tickets of spec <number>`.

As duas skills param para perguntar ao operador, como na checagem dos seams do
`anvil-to-spec` e na da granularidade do `anvil-to-tickets`. Na corrente, quem
responde é você, na mesma vez: escolha a opção que a skill recomenda ou, sem
recomendação, a mais conservadora, que mantém o que a skill propôs e não amplia o
escopo da entrada. Guarde a skill, a pergunta, a resposta e se ela era a
recomendada ou a mais conservadora. A mesma regra vale para as pausas do
`archive`, no fechamento.

### Despacho

É o laço de despacho da `anvil-run`, em série. No branch da spec, rode o script
dela, da instalação de usuário:

```bash
bash ~/.omp/agent/skills/anvil-run/frontier.sh [--skip "NN NN"]
```

1. Com `next: none`, o despacho acabou: siga para o `PASS`.
2. Despache o ticket da linha `next` com o `task`, numa chamada só, com um item:
   `agent` é `anvil-implementer`, `task` é o caminho do ticket e, com a linha
   `isolation` em `on` ou `misconfigured`, o item leva `isolated: true`. No
   `context`, diga a pasta da spec, o branch e o idioma de saída. O implementer
   é bloqueante: não chame outra ferramenta na mesma mensagem, e não leia o
   ticket, não investigue nem termine o trabalho dele.
3. Rode o script de novo e compare a linha do ticket com a de antes. Se `status`,
   `reviews` e `last` estão iguais, o ticket é pulado nesta execução: daí em
   diante, toda chamada leva o `--skip` com todos os pulados, e ele não é
   despachado de novo. Volte ao passo 1 com a última saída do script.

### `PASS`

A spec só fecha com `PASS`, que é, tudo junto:

- a última saída do `frontier.sh` com `all_resolved: yes` e sem linha `halt`;
- a última linha `Review:` de cada ticket de `issues/` em `verdict=pass; p1=none`;
- o bloco de `## Comando de verificação`, rodado por você na raiz, saindo `0`:

  ```bash
  bash -c "$(awk '$0 == "## Comando de verificação" {s=1; next} s && /^## /{exit} s && /^```bash$/{b=1; next} b && /^```$/{exit} b' .claude/rules/anvil.md)"; echo "exit: $?"
  ```

Guarde o comando, a saída e a linha `exit:` para o relatório. O `PASS` é o que o
disco e a execução mostram, e não o que o implementer disse.

### Fechamento

Com `PASS`, no branch da spec, carregue o `anvil-docs` no verbo `archive` e
commite o que ele moveu e escreveu:

```bash
git add -A
git commit -m "docs(spec): archive spec <number>"
```

O fechamento segue a regra do projeto: o perfil do tracker, na seção de fechar a
spec, mais as rules de `.claude/rules/`. Quando elas dizem que a spec fecha com
merge local, sem PR, mescle da `main`:

```bash
git checkout main
git merge --no-ff --no-edit <branch>
```

A guarda de merge confere esse merge como confere o do operador, e um bloqueio
dela é recusa, não sucesso. Ela não tem contorno: nenhum outro verbo leva o branch
para a `main`, como `git pull`, `git rebase`, `git reset` ou `git cherry-pick`, e
nada de `--no-verify`.

Com o merge parado em conflito, liste os arquivos com
`git diff --name-only --diff-filter=U`. Se o único é `docs/index.md`, gere o
índice de novo pelo verbo `index` do `anvil-docs` e conclua o merge. O bloco
custom é o único trecho escrito à mão, e nenhum lado o perde: leia o da `main`,
em `git show HEAD:docs/index.md`, e o do branch, em
`git show MERGE_HEAD:docs/index.md`. Iguais, o bloco fica como está; com um deles
vazio, vale o outro; diferentes, o bloco novo traz o texto da `main` e, depois
dele, o do branch. Depois:

```bash
git add docs/index.md
git commit --no-edit
```

### Relatório

Na `main`, depois do merge, rode o `roadmap.sh` e escreva `docs/specs/report.md`
inteiro, com tudo o que a execução fez até aqui, no idioma de comunicação das
rules. Há um relatório por execução: o primeiro desta execução substitui o da
anterior, que fica no git. Commite só ele:

```bash
git add docs/specs/report.md
git commit -m "docs(report): record spec <number> in the autopilot report"
```

O relatório tem esta forma, com uma seção de segundo nível por spec da execução,
na ordem, e as seções sem conteúdo ficam com "nenhum":

````markdown
# Relatório do piloto automático

Roteiro: `docs/specs/roadmap.md`, confirmado no commit <commit do sim>.

## <nome da entrada> — spec <number>

- Estado: fechada, com merge local na `main`
- Branch: `<branch>`

### Pausas respondidas pelo piloto

- `anvil-to-spec` — <pergunta> Resposta: <resposta> (<recomendada pela skill | a mais conservadora>).

### Tickets

- `<caminho do ticket>` — Status: <status>
  - Review: <cada linha Review: do ticket, como está>

### P2 e P3 que ficaram

- `<ticket>` — <a linha do ## Comments do ticket, como está>

### Travados em round=2

nenhum

### Comando de verificação

```text
$ <comando>
<saída>
exit: 0
```

### Pesquisas

nenhuma

### Decidido sem humano

- <o que você decidiu sozinho, fora das pausas, e por quê>

## Onde a corrente parou

<a entrada da linha next do roadmap.sh, que vem a seguir, ou, com next: none, que a corrente terminou sem entrada desbloqueada>

## O que ainda espera decisão

- <cada item como pergunta>?
````

## O fim

Com `next: none` no passo 1, a corrente terminou. Diga ao operador as specs que
fecharam nesta execução, cada uma com o branch e o merge na `main`, o caminho do
relatório e o commit dele. Termine a vez oferecendo um grill novo, com a lista de
"o que ainda espera decisão" do relatório como pauta. A oferta é a última coisa da
vez. Sem spec nesta execução, não há relatório novo: diga que nenhuma entrada
estava desbloqueada e ofereça o grill do mesmo jeito.

Aceita a oferta, volte à entrada, na `main`, que edita o mesmo roteiro e começa
uma execução nova. Recusada, pare.

## Fora do caminho feliz

Qualquer passo da corrente que não sai como descrito acima para a corrente ali:
uma recusa do `roadmap.sh`, o `new-spec.sh` que falha, um `halt` ou um ticket que
sobra sem resolver no despacho, o `PASS` que não vem, a regra do projeto que não
fecha por merge local, um merge bloqueado pela guarda ou um conflito fora do
`docs/index.md`. Nesse caso, não faça archive nem merge, não contorne a guarda e
não mexa no que ficou fora de commit. Termine a vez dizendo ao operador a
entrada, o passo, o motivo, o branch em que a execução ficou e o que está
commitado nele.

## Nunca

- Escrever arquivo, carregar o grill ou commitar antes de a largada passar.
- Commitar, criar branch ou rodar o `new-spec.sh` antes do sim.
- Mostrar para confirmação um roteiro que o `roadmap.sh` recusa, ou que perdeu uma
  entrada inacabada sem o abandono explícito dela.
- Tirar uma entrada inacabada do roteiro sem a resposta do operador sobre ela.
- Escrever `Spec:` fora do passo que abre a spec da entrada, ou mudar o nome ou o
  `Spec:` de uma entrada que fica.
- Usar um anexo de fora do repositório antes de ele estar em `docs/discovery/`.
- Guardar, commitar ou descartar o que o operador deixou fora de commit na largada.
- Perguntar ao operador entre o sim e o fim, ou ler o `anvil-next` dentro da
  execução.
- Fazer archive ou merge sem `PASS`, ou contornar a guarda de merge.
- Trocar de branch fora dos passos da corrente: a volta à `main` depois do
  `new-spec.sh`, o `git checkout -B` do branch recém-criado e a ida à `main` para
  o merge.
