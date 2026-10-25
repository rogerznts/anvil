---
name: anvil-auto
description: Piloto automático do anvil no omp. Recusa a largada indevida, conduz o grill sobre o plano inteiro de várias specs, ou a entrevista do anvil-bench quando o projeto tem a rule da stack do bench ou o argumento traz --bench, escreve o roteiro em docs/specs/roadmap.md e o commita no branch base com o único sim do operador. Depois, sem pausa, leva cada entrada do roteiro da spec ao fechamento, por merge local ou PR; no bench, o PASS é o --reverify do ledger da spec e dos das specs já fechadas. A spec que não fecha fica aberta no branch dela, e a corrente segue pelo que não depende dela, com relatório em docs/specs/report.md. Chamado no branch de uma spec aberta do roteiro, retoma a spec e segue a corrente.
argument-hint: "[--bench] o pedido, que vai para o grill ou para a entrevista do bench"
disable-model-invocation: true
---

# Piloto automático

O operador chamou esta skill com um pedido que pode ocupar várias specs. Você é o
piloto. Ele participa uma vez só: no grill, que cobre o plano inteiro e termina no
**roteiro** escrito em `docs/specs/roadmap.md`. A confirmação dele sobre o roteiro
escrito é o único sim da execução. Depois do sim, você conduz a **corrente** sem
pausa: cada entrada do roteiro vira uma spec, que vai da spec ao fechamento. A spec
que não fecha sozinha fica aberta no branch dela, e a corrente segue pelas entradas
que não dependem dela. A execução termina oferecendo um grill novo. Chamado no
branch de uma spec aberta, você retoma a spec e depois segue a corrente. Carregar
uma skill é lê-la com o `read` em `skill://<nome>` e segui-la.

O argumento, se veio, é o pedido. Um `--bench` no argumento não é parte do pedido:
é o sinal do modo bench, e sai do pedido.

## Modo bench

A execução está no **modo bench** quando o projeto tem a rule da stack do bench ou
quando o argumento traz `--bench`, e só nesses dois casos. A rule da stack do bench
é a que a fase 2 do `anvil-bench` gera, com a seção das invariantes do bench. Ela
existe quando isto sai com algum arquivo:

```bash
grep -l 'Invariantes do bench' .claude/rules/*.md 2>/dev/null
```

Nenhum outro sinal liga o modo: nem o pedido falar de ferramenta interna ou de
quem não programa, nem uma rule de stack sem essa seção, como a que o
`anvil-boot` escreve. Decida o modo na largada, antes do passo 3, e ele vale a
execução inteira. Fora do modo bench, não carregue o `anvil-bench`.

No modo bench, quem conversa com você não programa. O que muda está em cada seção,
nos trechos que começam por "No bench". Uma regra vale em todas: da entrada ao fim,
tudo o que você escreve no chat segue o INV-6 do bench, em português simples, sem
log, comando, caminho de arquivo, id, nome de branch nem nome de tecnologia. O
detalhe técnico vai para os arquivos: o roteiro, os tickets, o `decisions-log.md`
e o relatório.

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
   texto da `anvil-plan` e da `anvil-run`. Senão, guarde as linhas `branch`,
   `base`, `base_refusal`, `spec` e `next` para o passo 4.

2. **Árvore limpa.** Rode `git status --porcelain`. Com qualquer linha na saída,
   recuse: o piloto commita no branch base, e o que está fora de commit entraria
   num commit dele. Mostre o `git status --short` e diga que o operador commita ou
   guarda o que é dele e chama o piloto de novo. A árvore é do operador: você não
   roda `git stash`, `git commit`, `git checkout`, `git restore`, `git reset` nem
   `git clean`.

3. **Comando de verificação.** No modo bench, pule este passo: o `PASS` do bench é
   o `--reverify` dos ledgers, e não o comando. Fora dele, rode o script do
   comando, da instalação de usuário, na operação `check`:

   ```bash
   bash ~/.omp/agent/skills/anvil-auto/verification.sh check
   ```

   O script lê o bloco `bash` da seção de título exato `## Comando de verificação`
   de `.claude/rules/anvil.md` e, saindo `0`, imprime o comando. Uma linha
   `refusal:` é recusa, com o motivo dela: o piloto só fecha uma spec com o comando
   de verificação do projeto rodado por ele saindo `0`, e sem comando nenhuma spec
   fecha. A mensagem diz onde e como declarar: em
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

4. **Branch.** Pela saída do passo 1. Com `base: none`, recuse com as linhas
   `base_refusal`, copiadas como estão: são o motivo do resolvedor, o
   `resolve-git.sh` do `anvil-docs`, e dizem como sair dela. Só a recusa do branch
   base para a largada: uma de forge ou de login, como num Gitea sem `tea` ou sem a
   seção `## Git`, não sai no `base_refusal` e só pesa no fechamento por PR. Senão,
   a linha `base` é o **branch base**, de onde a corrente parte e para onde cada
   spec volta: `<base>` nos comandos daqui em diante. Com a linha `branch` igual à
   `base`, siga para a entrada. Em outro branch, a linha `do:` do script é da
   `anvil-plan` e não vale aqui: você não propõe etapa nem termina a vez por ela.
   Decida assim:
   - com `next: none`, o branch é de uma spec arquivada, a da linha `spec`: recuse
     e aponte o branch base. Quando `git merge-base --is-ancestor HEAD <base>` sai
     diferente de `0`, a spec está arquivada no branch e ainda sem merge no branch
     base, como a que a conferência do merge parou: a recusa diz esse motivo, e
     que o piloto não retoma a spec nem refaz o merge dela, porque qual spec cede
     é decisão do operador;
   - com `spec: none`, retome pela seção "Retomada" quando o branch tem número,
     `{tipo}/{NNN}-{nome}`, e esse número está no `Spec:` de uma entrada do
     roteiro: a spec nasceu e ainda não tem pasta commitada. Senão, recuse, aponte
     o branch base e diga o motivo da linha `reason`;
   - nos outros casos, a spec da linha `spec` está aberta: retome pela seção
     "Retomada".

   Numa recusa, trocar de branch é escolha do operador.

## Entrada

No branch base, a entrada é o `anvil-grill` ou, no modo bench, a entrevista do
`anvil-bench`, com o pedido como ponto de partida. Sem pedido no argumento e sem
nada do plano nesta conversa, peça o pedido e pare.

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
spec, e o `Spec:` liga a entrada à pasta dela. No bench, a pergunta nomeia a parte
da ferramenta que a entrada constrói, em português simples, e não o nome da
entrada.

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

### A entrevista do bench

No modo bench, a entrada não é o grill. Carregue o `anvil-bench` e siga as fases 1
a 3 dele, como ele é, com o que a seção dele "Sob o piloto automático" diz: o
ambiente, o reconhecimento do projeto e a entrevista, que lê o que o projeto já tem
antes de perguntar e cobre a ferramenta inteira. O roteiro que já existe, o
abandono e o anexo seguem as seções acima. A entrevista termina com o
`docs/discovery/briefing.md`, o `docs/qa/checklist.yaml` e o
`docs/specs/roadmap.md` escritos, com `Cobre:` em cada entrada, e daí vale o que
segue.

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

No bench, quem escreve o roteiro é a entrevista, e a conferência 1 é a do bench: a
recusa do `roadmap.sh` e a cobertura do checklist que não fecha são erro seu, e
você corrige os arquivos sem perguntar, como a fase 3 dele manda. A conferência 2
vale como está, com a pergunta da entrevista.

### Mostrar e confirmar

Só o roteiro que passou nas duas conferências é mostrado. Leia o arquivo do disco e
mostre-o inteiro, como está escrito, e termine a vez perguntando se este é o
roteiro que o piloto vai executar. No bench, o arquivo não aparece: mostre a versão
dele em português simples, como a fase 3 do bench diz, com as partes na ordem em
que vão ser feitas, o que entra e o que fica de fora de cada uma e como a pessoa
vai saber que cada uma está pronta, e pergunte se é isso que vai ser feito. A
pergunta é a última coisa da vez. A resposta decide:

- sim: siga para a seção seguinte;
- uma correção ou uma pergunta: responda e volte ao grill no ponto que ela abriu.
  Depois, escreva, valide e mostre de novo, com a mesma pergunta;
- não, sem correção: pare sem commitar. O que foi escrito fica na árvore, e o
  destino dele é escolha do operador.

### Com o sim

Commite no branch base, num commit só, tudo o que a entrada escreveu: o roteiro, as
cópias de anexo em `docs/discovery/`, e os ADRs e o glossário do grill. A árvore
estava limpa na largada, então tudo o que está fora de commit veio da entrada.

No bench, antes do commit, atualize a rule da stack com os módulos e os papéis
reais, como diz "O combinado, uma vez", da fase 4 do bench. O commit leva também o
briefing, o checklist e, num projeto novo, o starter, a rule da stack e os perfis do
tracker e de verificação que a fase 2 escreveu: o bench não commita sob o piloto.

```bash
git add -A
git commit -m "docs(roadmap): record the roadmap confirmed by the operator"
```

Se a entrada não mudou nenhum arquivo, não há o que commitar: o roteiro
confirmado já está no branch base. Anote o commit dele com
`git rev-parse --short HEAD`, para o relatório, e siga para a corrente na mesma
vez, sem esperar resposta.

## Retomada

Chamado no branch de uma spec aberta, você não passa pela entrada: o roteiro foi
confirmado numa execução anterior, e não há grill nem sim. Rode o `roadmap.sh` e
ache a linha `entry:` cujo `spec=` tem o número do branch, comparado como número.
Sem ela, recuse: a spec não é de uma entrada do roteiro, e quem a conduz é a
`anvil-plan` e a `anvil-run`. Com ela, a entrada desta volta é essa: leia a seção
dela no `roadmap.md` e retome a spec do ponto que o disco indica, pela linha `next`
do `stage.sh` da largada:

- `anvil-grill`, no branch com número e sem pasta, ou `anvil-to-spec`: escreva a
  spec e os tickets, como diz "Spec e tickets";
- `anvil-to-tickets`: a spec existe, e você escreve só os tickets, na segunda parte
  de "Spec e tickets";
- `end`: siga para o "Despacho". O `frontier.sh` diz o que falta construir, e, com
  todo ticket resolvido, o despacho acaba de saída e vai para o `PASS`;
- `anvil-wayfinder`: o `map.md` da spec tem decisão aberta, e decisão é do
  operador. A spec fica parada, como diz "Parada", com a decisão em "o que ainda
  espera decisão".

No bench, a pasta da spec sem `gates.md` pede o "Ledger da spec" antes de qualquer
um desses pontos.

O que o disco já tem não se refaz: a spec, os tickets resolvidos e os commits do
branch ficam como estão. Daí em diante, a spec segue os passos da corrente como
qualquer outra, até fechar ou parar, e o relatório dela é o primeiro desta
execução. Depois, o laço volta ao passo 1, no branch base.

## Corrente

Do sim, ou da largada de uma retomada, até o fim, conduza sem pausa: não pergunte
nada ao operador e não termine a vez entre uma spec e outra. O estado é o disco,
relido a cada passo, e não esta conversa. Dentro desta execução, quem decide o
próximo passo é você: quando uma skill de etapa termina, siga a corrente, sem ler o
`anvil-next`.

Guarde na conversa, para o relatório, o que cada spec deixar: as pausas que você
respondeu, a saída do comando de verificação ou do `--reverify`, as pesquisas e,
quando ela para, o motivo.

No bench, o que você decide sozinho numa spec, as pausas respondidas e o que vai
para "Decidido sem humano", vai também para o `decisions-log.md` na raiz da pasta
da spec, como o bench faz na construção: uma linha por decisão, com o porquê. Ele
é commitado no branch da spec junto do commit seguinte, e o `PASS` e a "Parada"
não deixam o branch sem ele.

O laço, a partir do branch base:

1. Rode o `roadmap.sh`, com as entradas puladas nesta execução no `--skip`, se
   houver alguma:

   ```bash
   bash ~/.claude/skills/anvil-docs/scripts/roadmap.sh [--skip "nome nome"]
   ```

   Com `next: none`, vá para o fim. Senão, a entrada desta volta é a da linha
   `next`: leia a seção dela no `roadmap.md`.
2. Confira a entrada contra o código.
3. Abra a spec e, no bench, escreva o ledger dela.
4. Escreva a spec e os tickets.
5. Despache os tickets.
6. Confira o `PASS`.
7. Feche a spec.
8. Escreva o relatório no branch base, commite e volte ao passo 1.

A spec que não chega ao fim do passo 7 fica parada no branch dela, como diz
"Parada", e o laço segue do passo 8. Só o `roadmap.sh` escolhe a próxima entrada:
uma entrada que depende, direta ou indiretamente, de outra que não está `closed`
nunca sai no `next`, e você não a começa por conta própria. Os poucos passos que
param a execução inteira estão em "Fora do caminho feliz".

### Conferir a entrada

Antes de abrir a spec, no branch base, confira a entrada contra o código atual.
Leia o `Entra:`, o `Fica de fora:` e o `Pronto quando:`, e o código que eles
citam, como arquivos, comandos e telas, como está no branch base. A pergunta é
uma só: o `Pronto quando:` ainda se cumpre fazendo o que o `Entra:` diz, sem o
que o `Fica de fora:` exclui, sobre o código que existe?

- Cumpre-se, mesmo pedindo um ajuste de detalhe: siga para abrir a spec. O ajuste
  vai para a spec, e para o relatório como "decidido sem humano".
- Não se cumpre, porque o critério pede o que o código não tem e a entrada não
  deixa fazer, ou o código já faz de outro jeito que a entrada não deixa mudar: a
  entrada para antes de nascer. Não rode o `new-spec.sh`, não escreva `Spec:` e
  não crie branch. Acrescente o nome dela à lista do `--skip` desta execução,
  escreva o relatório no branch base com a entrada, o que o critério pede, o que o
  código tem e a pergunta que o operador responde, commite-o como diz "Relatório"
  e volte ao passo 1.

Em nenhum dos casos a entrada muda: `Entra:`, `Fica de fora:` e `Pronto quando:`
são do operador, e só um grill novo os altera.

### Abrir a spec

No branch base, rode o script de spec nova, da instalação de usuário, com o
`Tipo:` e o nome da entrada:

```bash
bash ~/.claude/skills/anvil-to-spec/scripts/new-spec.sh --type <Tipo> --short-name <nome> --json
```

O JSON da saída dá o número, em `number`, e o branch, em `branch`, e vale sobre
qualquer previsão. O script deixa o checkout no branch novo, ainda sem commit.
Então, nesta ordem, cada passo depois do anterior, nunca em chamadas paralelas:

1. Volte ao branch base com `git checkout <base>`.
2. No `roadmap.md`, acrescente a linha `Spec: <number>` à seção da entrada, junto
   das outras chaves: logo abaixo de `Depende de:` ou, sem ela, de `Tipo:`. É a
   única mudança no roteiro.
3. Commite só o roteiro e leve o branch da spec até esse commit, voltando a ele,
   num comando só:

   ```bash
   git add docs/specs/roadmap.md && git commit -m "docs(roadmap): record spec <number> for <nome>" && git checkout -B <branch> <base>
   ```

   Em duas chamadas paralelas, o checkout pode vir antes do commit, e o `Spec:`
   cai no branch da spec, e não no branch base. O branch acabou de nascer e não tem
   commit próprio, então o `-B` só o avança. Assim o `Spec:` está no branch base
   antes de qualquer commit da spec, e o branch o contém.

### Ledger da spec

No bench, no branch da spec e antes do `anvil-to-spec`, rode "O ledger de cada
spec", da fase 4 do `anvil-bench`, para a entrada desta volta: os testes derivados
só dos itens do `Cobre:` dela, o `gates.md` na raiz da pasta da spec, a do
`spec_dir` do JSON do `new-spec.sh`, e o `gate-lint` sobre ele. Commite os testes e
o ledger no branch:

```bash
git add -A
git commit -m "test(<nome>): add the ledger of spec <number>"
```

O ledger nasce antes da spec, como no bench: o `Pronto quando:` da entrada já tem,
no `gates.md`, o que decide o `PASS` dela.

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
`archive` e do `anvil-open-pr`, no fechamento.

Se, ao escrever a spec ou os tickets, o código contradiz a entrada, siga
"Contradição com o roteiro".

### Despacho

É o laço de despacho da `anvil-run`, em série. No branch da spec, rode o script
dela, da instalação de usuário:

```bash
bash ~/.omp/agent/skills/anvil-run/frontier.sh [--skip "NN NN"]
```

1. Com `next: none` e sem linha `halt`, o despacho acabou. Com
   `all_resolved: yes`, siga para o `PASS`. Senão, sobrou ticket sem resolver:
   travado, dependente de travado, pulado ou sem como despachar. Leia o
   `## Comments` de cada um: uma contradição entre o código e a entrada segue
   "Contradição com o roteiro"; o ticket da linha `locked`, e o pulado em que o
   implementer parou numa pergunta de fato, seguem "Pesquisa antes de travar"; o
   resto para a spec, como diz "Parada".
2. Despache o ticket da linha `next` com o `task`, numa chamada só, com um item:
   `agent` é `anvil-implementer`, `task` é o caminho do ticket e, com a linha
   `isolation` em `on` ou `misconfigured`, o item leva `isolated: true`. No
   `context`, diga a pasta da spec, o branch e o idioma de saída. O implementer
   é bloqueante: não chame outra ferramenta na mesma mensagem, e não leia o
   ticket, não investigue nem termine o trabalho dele.
3. Rode o script de novo e compare a linha do ticket com a de antes. Se `status`,
   `reviews` e `last` estão iguais, o implementer terminou sem mudar o estado: anote
   o ticket como pulado nesta execução e, com o pulado novo, rode o script mais uma
   vez, já com o `--skip` de todos os pulados. Daí em diante, toda chamada leva o
   `--skip` com todos os pulados, e o pulado não é despachado de novo nesta
   execução, nem quando o implementer caiu, abortou ou devolveu erro. Só a
   "Contradição com o roteiro" e o "Abrir a rodada" o tiram do `--skip`. Volte ao
   passo 1 com a última saída do script: com pulado novo, a do `--skip`, cujo
   `next` nunca aponta um pulado.

### `PASS`

A spec só fecha com `PASS`, que é, tudo junto:

- a última saída do `frontier.sh` com `all_resolved: yes` e sem linha `halt`;
- a última linha `Review:` de cada ticket de `issues/` em `verdict=pass; p1=none`;
- fora do bench, o bloco de `## Comando de verificação`, rodado pelo script na
  operação `run`, saindo `0`. O script roda o bloco da raiz do projeto, imprime a
  saída do comando e, por último, a linha `exit:` com o código dele. Antes, a
  operação `check` imprime o comando que vai para o relatório:

  ```bash
  bash ~/.omp/agent/skills/anvil-auto/verification.sh check
  bash ~/.omp/agent/skills/anvil-auto/verification.sh run
  ```

  Rode o bloco só pelo script, e nunca um comando digitado por você. Uma linha
  `refusal:` no lugar da linha `exit:` conta como o comando saindo diferente de
  `0`.

- no bench, o `--reverify` acumulado com a saída que vale o `PASS` pela regra do
  `GATE.md`, como diz a seção seguinte.

Guarde o comando, a saída e a linha `exit:` para o relatório. O `PASS` é o que o
disco e a execução mostram, e não o que o implementer disse. Com os tickets em
ordem e o comando saindo diferente de `0`, ou o `--reverify` sem valer o `PASS`,
siga "Pesquisa antes de travar", menos quando a regra do `GATE.md` dá à saída do
`--reverify` a spec parada por decisão, como diz a seção seguinte. Nos outros
casos, sem `PASS`, a spec fica parada, como diz "Parada".

#### O `--reverify` do bench

No bench, no branch da spec, leia o `GATE.md` do bench, em
`skill://anvil-bench/GATE.md`, e rode você o comando da seção "A evidência". Ele
reexecuta o `gates.md` desta spec e o de cada spec do roteiro já `closed`, que o
`roadmap.sh` lê no checkout do branch, e devolve os ledgers das specs fechadas como
estavam: uma spec arquivada não muda.

A seção "Sob o piloto automático" do mesmo `GATE.md` é a regra que lê a saída e a
linha `exit:`, e dá o desfecho, inclusive qual vale quando mais de um gate segura
o `PASS`. Tire o desfecho só dela. O que você faz com cada um:

- **a saída que vale o `PASS`**: é o item do bench no `PASS`, e a spec segue para
  o "Fechamento" com os outros itens dele.
- **o `FAIL` no teto**: siga "Pesquisa antes de travar", como a verificação que
  falha. O gate de uma spec fechada que caiu é regressão: esta spec não fecha
  enquanto ele não voltar a passar.
- **a spec parada por decisão**: a spec fica parada, como diz "Parada", sem
  pesquisa.

Cada gate manual aberto que a regra manda para "o que ainda espera decisão" vai
com a pergunta formulada: quem confere que <o título do gate>, e com que
evidência, para marcar o gate `<id>` no `gates.md` da spec dele.

Um gate manual se marca só com a evidência de quem conferiu: nem você nem o
implementer o marcam. Depois de ler a saída, commite no branch o que mudou na
pasta da spec, como o que o checker escreveu no ledger dela e o
`decisions-log.md`, se mudou alguma coisa:

```bash
git add docs/specs/<pasta>
git commit -m "docs(spec): record the gate run of spec <number>"
```

### Fechamento

Com `PASS`, no branch da spec, carregue o `anvil-docs` no verbo `archive` e
commite o que ele moveu e escreveu:

```bash
git add -A
git commit -m "docs(spec): archive spec <number>"
```

Antes de toda volta ao branch base no fechamento, confira a árvore: no merge
local, logo depois do commit do archive; no PR, depois do push da linha `PR:`.
Rode `git status --porcelain`. Com qualquer linha na saída, a execução para, como
diz "Fora do caminho feliz", com os arquivos no motivo: não volte ao branch base,
não faça o merge e não mexa nesses arquivos. O que o archive ou o `anvil-open-pr`
deixou fora de commit iria para o branch base com você.

O fechamento segue as rules e o forge do projeto. Rode o resolvedor, da instalação
de usuário, o mesmo que deu o branch base na largada:

```bash
bash ~/.claude/skills/anvil-docs/scripts/resolve-git.sh
```

Ele dá os valores que resolveu e uma linha `refusal: <campo>: <motivo>` por
recusa. Decida, nesta ordem, e pare na primeira que decide:

1. Com `remote: none`, o projeto não tem remoto, e a spec fecha por merge local.
2. Leia a seção de fechar a spec do perfil do tracker,
   `docs/agents/issue-tracker.md`, e cada arquivo de `.claude/rules/` inteiro, com
   o `read`, e não por busca de palavra: a rule pode dizer isso de muitos jeitos,
   num trecho sobre o fluxo git ou o fechamento. Quando uma rule diz que o projeto
   fecha sem PR, ou o perfil não tem o passo `/anvil-open-pr`, a spec fecha por
   merge local, sem consultar o forge: as linhas `forge:` e `refusal: forge:` não
   contam.
3. Senão, o forge decide. Com uma linha `refusal: forge:`, a spec fica parada, como
   diz "Parada", com essas linhas no motivo, copiadas como estão: elas dizem o que
   declarar ou corrigir. Com `forge: nenhum`, a spec fecha por merge local, mesmo
   que o perfil do tracker fale de PR: um remoto sem forge não tem onde abrir o PR.
   Com `forge: github` ou `forge: gitea`, ela fecha por PR.

A guarda de merge confere o `git merge`, o `gh pr create` e o `tea pr create` como
confere os do operador, e um bloqueio dela é recusa, não sucesso: a spec fica
parada, como diz "Parada". Ela não tem contorno: nenhum outro verbo leva o branch
para o branch base, como `git pull`, `git rebase`, `git reset` ou
`git cherry-pick`, e nada de `--no-verify`.

#### Merge local

Com a árvore limpa, vá ao branch base e confira se ele tem commits que o branch
da spec não tem:

```bash
git checkout <base>
git rev-list --count <branch>..<base>
```

Com `0`, o branch base não andou desde o corte do branch, e o `PASS` já rodou
sobre a árvore que o merge dá. Mescle sem conferir de novo:

```bash
git merge --no-ff --no-edit <branch>
```

Com mais de `0`, o branch base andou, como quando uma spec irmã fechou depois do
corte, e o `PASS` do branch não rodou sobre o código dela. Prepare o merge sem
commitá-lo e siga "Conferir o merge":

```bash
git merge --no-ff --no-commit <branch>
```

A guarda confere esse `git merge` como confere o outro, e passa, porque a spec já
está arquivada no branch. O `git commit` que conclui o merge não é verbo de merge.

Com o merge parado em conflito, liste os arquivos com
`git diff --name-only --diff-filter=U`. Se o único é `docs/index.md`, gere o
índice de novo pelo verbo `index` do `anvil-docs`. O bloco custom é o único
trecho escrito à mão, e nenhum lado o perde: leia o do branch base, em
`git show HEAD:docs/index.md`, e o do branch da spec, em
`git show MERGE_HEAD:docs/index.md`. Iguais, o bloco fica como está; com um deles
vazio, vale o outro; diferentes, o bloco novo traz o texto do branch base e, depois
dele, o do branch. Depois:

```bash
git add docs/index.md
```

No merge preparado com `--no-commit`, siga "Conferir o merge" com o índice já
resolvido; no outro, conclua o merge com `git commit --no-edit`.

Com qualquer outro arquivo na lista, o conflito não é seu: aborte o merge com
`git merge --abort`, sem resolver nada, e a spec fica parada, como diz "Parada",
com os arquivos em conflito no motivo.

##### Conferir o merge

Com o merge preparado e sem conflito aberto, no branch base, rode a verificação
sobre o estado combinado:

- fora do bench, o script do comando, como no `PASS`, com `check` e depois `run`.
  A conferência sai `0` com a linha `exit: 0`; uma linha `refusal:` conta como
  diferente de `0`;
- no bench, o comando de "A evidência" do `GATE.md` sem o
  `docs/specs/<pasta>/gates.md`. Com o merge preparado, a pasta desta spec está em
  `docs/specs/archive/`, o `roadmap.sh` a dá como `closed`, e o `$fechados` já traz
  o ledger dela, junto dos das specs `closed`, inclusive a que fechou no branch base
  depois do corte. A saída que vale o `PASS` pela regra de "Sob o piloto
  automático" conta como `0`; qualquer outra, como diferente de `0`. Antes de
  concluir ou abortar, `git diff --name-only` mostra o que o checker reescreveu
  fora do merge: devolva esses ledgers com `git checkout -- <arquivos>`, porque
  uma spec arquivada não muda.

Guarde o comando, a saída e a linha `exit:` para o relatório, junto dos do `PASS`.

Saindo `0`, conclua o merge com a mensagem padrão:

```bash
git commit --no-edit
```

Saindo diferente de `0`, esta spec e o que já fechou no branch base não passam
juntos. Aborte o merge, sem corrigir nada:

```bash
git merge --abort
```

A spec fica parada, como diz "Parada", já arquivada no branch. É parada por
decisão: sem pesquisa e sem rodada extra. Na seção dela no relatório, o `Estado:`
diz que a verificação falhou sobre o merge com o branch base, e a seção do
comando de verificação, ou do `--reverify`, leva a saída da conferência. Em "o
que ainda espera decisão", a pergunta é qual spec cede: esta ou as que fecharam
no branch base depois do corte, as que a saída aponta.

#### PR

Antes de levar o branch ao remoto, confira o que o PR pede. Rode o resolvedor com
`--pr`, que no Gitea procura também o login do `tea`:

```bash
bash ~/.claude/skills/anvil-docs/scripts/resolve-git.sh --pr
```

Com qualquer linha `refusal:`, de branch base, forge ou login, a spec fica parada,
como diz "Parada", sem `git push` e sem `pr create`. O motivo são essas linhas,
inteiras e copiadas como estão, com o `refusal: <campo>:` do começo, porque elas
dizem o que declarar ou corrigir, como o `tea login` que falta. No relatório, elas
vão no próprio `Estado:` da spec, e não num resumo delas:

```text
- Estado: parada no branch: resolvedor com --pr, antes do push: <cada linha refusal:, como veio>
```

Sem recusa, guarde o `<base>`, o `<repo>` e, no Gitea, o `<login>` que ele deu.

Leve então o branch ao remoto, abra o PR pelo `anvil-open-pr` e pare ali, sem
merge. O remoto é o `origin`, o que o resolvedor leu:

```bash
git push -u origin <branch>
```

No branch da spec, carregue o `anvil-open-pr` e siga-o, com uma mudança: o Step 0
dele usa o `<base>`, o `<repo>` e o `<login>` que você conferiu antes do push, e
não roda o resolvedor de novo, como no Step 6 do `anvil-open-fast-pr`. Ele abre o
PR no forge do resolvedor, com o `gh` ou o `tea`. As pausas dele seguem a regra das
pausas, e a base do PR é o branch base, de onde a corrente parte. Quando a skill
para antes de devolver a URL do PR, a spec fica parada, como diz "Parada", com o
motivo dela. Depois que a skill commita a linha `PR:` nos tickets, leve esse
commit ao remoto com `git push`, e guarde a URL do PR.

Não faça o merge, nem o do PR nem um local: a revisão do PR é do operador. A
entrada fica `stopped` até o merge do PR, e as que dependem dela esperam. Confira a
árvore, como diz "Fechamento", e, limpa, volte ao branch base com
`git checkout <base>` e siga para o relatório, com o PR em "o que ainda espera
decisão".

### Contradição com o roteiro

Uma contradição entre o código e a entrada pode aparecer depois que a spec nasceu:
ao escrever a spec ou os tickets, ou no `## Comments` de um ticket, onde o
implementer registra o que a implementação mostrou de errado na spec. Ela segue a
régua da conferência da entrada:

- Com o `Pronto quando:` ainda cumprível, adapte dentro da spec: a `spec.md` e os
  tickets, nunca o roteiro. Commite a adaptação no branch, com
  `docs(spec): adapt spec <number> to <o que mudou>`, e registre em "Decidido sem
  humano" o que mudou e por quê. O ticket que o implementer deixou sem resolver por
  causa dela sai do `--skip` e volta ao despacho uma vez.
- Com o critério incumprível, a spec fica parada, como diz "Parada", e a
  contradição vai para "o que ainda espera decisão". Achada antes de os tickets
  estarem completos, ao escrever a spec ou os tickets, ela deixa o rascunho fora de
  commit. Commite no branch da spec o que você escreveu na pasta dela, só essa
  pasta, e só então siga a "Parada":

  ```bash
  git add docs/specs/<pasta>
  git commit -m "docs(spec): stop spec <number> at a draft"
  ```

  Sem nada novo na pasta, não há o que commitar.

### Pesquisa antes de travar

Antes de deixar uma spec parada por motivo técnico, pesquise em fontes primárias:
a parada pode ser falta de uma informação pública. São três as paradas técnicas:

- **ticket travado**: o ticket da linha `locked` do `frontier.sh`, com a última
  `Review:` em `round` 2 ou mais e `verdict=fail`;
- **verificação que falha**: no `PASS`, o comando de verificação sai diferente de
  `0` ou, no bench, o `--reverify` dá o `FAIL` no teto;
- **implementer bloqueado por fato desconhecido**: o ticket pulado no despacho em
  que o implementer registrou no `## Comments` uma pergunta que uma fonte pública
  responde, como o comportamento de uma ferramenta, de uma biblioteca, de uma API
  ou de um formato. A pergunta sobre o que o operador quer é decisão.

A parada por decisão não pesquisa e vai direto para "Parada": a spec que a regra
do `GATE.md` deixa parada por decisão no `--reverify`, o PR aberto, a contradição
com o roteiro, a decisão aberta do `map.md`, o merge bloqueado pela guarda,
abortado por conflito ou abortado pela conferência do merge, e o ticket que só
depende de um travado, que espera a pesquisa do travado.

A rodada extra é uma só por ticket, em qualquer execução, e o registro dela é o
disco: a linha `- Piloto · rodada` no `## Comments` do ticket. O ticket que já tem
essa linha não recebe outra rodada, e a parada dele não pesquisa de novo: a spec
fica parada. A verificação que falha pesquisa uma vez por spec em cada execução.

#### Pesquisar

O arquivo da pesquisa fica na pasta da spec, no branch dela:
`docs/specs/<pasta>/discovery/research-<parada>.md`, com `ticket-<NN>` ou
`verification` no lugar de `<parada>`, e `-2`, `-3` no fim do nome quando o
arquivo já existe.

Carregue o `anvil-research` e siga-o. O agente que ele manda abrir é um item do
`task`, com o agente padrão, e você espera o resultado antes de seguir: a corrente
depende dele. O brief leva:

- a pergunta: o que explica a falha, e o que a corrige;
- o material da parada: do ticket travado, o caminho dele, as linhas `Review:` e
  as linhas `open_p1` do `frontier.sh`; da verificação, o comando, a saída, a linha
  `exit:` e os caminhos dos tickets da spec, e, no bench, os `gates.md`
  reexecutados; do implementer bloqueado, o caminho do ticket e a pergunta dele;
- as fontes: primárias e na web, como documentação oficial, código-fonte,
  especificação e API de primeira mão, cada afirmação com a URL que a sustenta;
- o caminho do arquivo, e que o agente grava só esse arquivo, sem commitar;
- que o arquivo termina nesta seção, preenchida:

  ```markdown
  ## Conclusão

  - Fonte que explica a falha: <URL> | nenhuma
  - Ticket que ela aponta: <caminho do ticket em issues/> | nenhum
  - Correção: <o que mudar, numa frase> | nenhuma
  ```

- o idioma de saída, o de comunicação das rules.

Se o agente voltou sem gravar o arquivo, grave você o que ele devolveu no mesmo
caminho, com a mesma `## Conclusão`. Commite no branch da spec:

```bash
git add docs/specs/<pasta>/discovery/<arquivo>
git commit -m "docs(spec): record the research on <ticket NN | the verification> of spec <number>"
```

#### Decidir a rodada

Leia a `## Conclusão`. A rodada extra só abre com as quatro condições, conferidas
nesta ordem, e a primeira que falta é o motivo de não abrir:

1. **Ticket apontado.** A conclusão aponta um ticket do `issues/` desta spec. Sem
   ticket, não há rodada.
2. **Evidência nova.** Há fonte que explica a falha, e ela ainda não está no
   ticket apontado: `grep -F '<URL>' <ticket>` não acha nada. Fonte já citada no
   ticket não é nova.
3. **Sem laço.** O histórico desse ticket, com as linhas `Review:` e as linhas
   `Review round=N · …` do `## Comments`, não mostra dois dos sinais de laço de
   `docs/agents/verification.md`: a rodada N+1 acha o que a rodada N criou; a
   classe dos achados desce em vez de subir; nenhum achado nomeia uma decisão que
   muda; mesmo custo por rodada, achado menor. Com menos de duas linhas `Review:`,
   não há rodada com que comparar, e nenhum sinal está presente. Com dois sinais, a
   rodada não abre mesmo com evidência, e o motivo nomeia os dois.
4. **Uma só.** O `## Comments` do ticket apontado ainda não tem linha
   `- Piloto · rodada`, de nenhuma execução.

Sem rodada, a spec fica parada, como diz "Parada". O relatório leva o arquivo e o
motivo, e a pergunta de "o que ainda espera decisão" cita o ticket e o arquivo.

#### Abrir a rodada

A rodada extra é a seguinte à última `Review:` do ticket apontado: `round=N+1`,
ou `round=1` quando ele não tem `Review:`. É a exceção declarada ao ADR-0010 do
anvil, o que fecha a verificação em duas rodadas, e a declaração fica no ticket:

1. Acrescente ao fim do `## Comments` do ticket apontado, que é a única linha de
   ticket que você escreve:

   ```markdown
   - Piloto · rodada <N+1> aberta por `docs/specs/<pasta>/discovery/<arquivo>`: <a fonte e o que ela explica da falha>.
   ```

   Commite no branch da spec com
   `docs(spec): open round <N+1> of ticket <NN> of spec <number>`.
2. Despache um `anvil-implementer` para esse ticket, como no passo 2 do
   "Despacho", com o caminho do arquivo da pesquisa no `context`, junto da pasta da
   spec, do branch e do idioma de saída. O ticket sai do `--skip`, se estava nele.
3. Volte ao passo 1 do "Despacho". Com o ticket resolvido, o despacho segue e o
   `PASS` é conferido de novo; com ele parado outra vez, a spec fica parada.

### Parada

A spec que não fecha sozinha fica aberta no branch dela, e a corrente segue. Para
aqui a spec que:

- termina o despacho com ticket sem resolver, depois da pesquisa quando a parada é
  técnica;
- não tem `PASS`, depois da pesquisa quando o que falha é o comando de
  verificação ou o `--reverify`;
- fica parada por decisão pela regra do `GATE.md`, no `--reverify` do bench;
- esbarra numa contradição incumprível, ou numa decisão aberta do `map.md`;
- não fecha no fechamento: o forge que o resolvedor recusa, a recusa do resolvedor
  com `--pr`, antes do push, a parada do `anvil-open-pr`, o merge bloqueado pela
  guarda, o merge abortado por conflito fora do `docs/index.md` ou pela conferência
  do merge, ou o PR aberto, à espera do merge do operador.

Depois disso, não faça archive nem merge dela e não mexa no que está commitado no
branch. No bench, commite antes no branch o `decisions-log.md` da spec, se ele
mudou desde o último commit. Confira com `git status --porcelain` que a árvore está
limpa: com linha na saída, a execução para, como diz "Fora do caminho feliz". Com a
árvore limpa, volte ao branch base com `git checkout <base>`, se ainda não está
nele, e siga para o relatório. Guarde para ele o passo em que a spec parou, o
motivo, como a saída do `frontier.sh`, do comando de verificação ou do
`--reverify`, e a pergunta que a destrava.

Na volta ao passo 1, o `roadmap.sh` dá a entrada como `stopped` ou `open`, e
nenhuma entrada que depende dela entra no frontier: a corrente segue pelas que não
dependem.

### Relatório

Escreva `docs/specs/report.md` no branch base, a cada fronteira de spec: depois do
merge local; quando a spec fica parada ou com o PR aberto, já de volta ao branch
base; e quando uma entrada para antes de nascer, na conferência. Rode o
`roadmap.sh` e escreva o arquivo inteiro, com tudo o que a execução fez até ali,
no idioma de comunicação das rules. Há um relatório por execução: o primeiro desta
execução substitui o da anterior, que fica no git. Commite só ele:

```bash
git add docs/specs/report.md
git commit -m "docs(report): record <nome da entrada> in the autopilot report"
```

O relatório tem esta forma, com uma seção de segundo nível por entrada tocada na
execução, na ordem, e as seções sem conteúdo ficam com "nenhum". No bench, a seção
de cada spec traz o `decisions-log.md` dela, lido do branch com
`git show <branch>:<caminho>` pelo caminho que ele tem lá: com o archive da spec
commitado no branch, como na spec fechada e na parada no fechamento depois do
archive, o caminho é `docs/specs/archive/<pasta>/decisions-log.md`; na spec parada
antes do archive, `docs/specs/<pasta>/decisions-log.md`. No bench também, o
`--reverify` vem no lugar do comando de verificação:

````markdown
# Relatório do piloto automático

Roteiro: `docs/specs/roadmap.md`, <confirmado no commit <commit do sim> | execução retomada no branch <branch>, na etapa <next do stage.sh>>.

## <nome da entrada> — spec <number>

- Estado: <fechada, com merge local no `<base>` | PR aberto, <URL>, à espera do merge | parada no branch: <passo e motivo>>
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

### <Comando de verificação | --reverify do bench>

```text
$ <comando>
<saída>
exit: 0
```

### decisions-log.md

<no bench, o decisions-log.md da spec, como está no branch; fora do bench, a seção não existe>

### Pesquisas

- `<caminho do arquivo>` — parada: <ticket NN travado em round=N | comando de verificação saindo <exit> | --reverify com gate caído: <ids> | ticket NN bloqueado: <a pergunta>>. Rodada: <aberta, round=<N> no ticket NN, com a última Review: dele depois do despacho | não aberta: <a evidência não aponta ticket | sem evidência nova | sinais de laço: <os dois> | o ticket já teve a rodada extra, pela linha do piloto no ## Comments>>

### Decidido sem humano

- <o que você decidiu sozinho, fora das pausas, e por quê>

## <nome da entrada> — parada antes da spec

- Estado: pulada nesta execução, sem `Spec:` e sem branch
- Contradição: <o que o Pronto quando pede e o que o código tem>

## Onde a corrente parou

<cada entrada que não fechou, com o estado e o motivo do roadmap.sh e, se ela parou nesta execução, a causa do `Estado:` da seção dela, como o PR aberto ou o merge abortado, porque o motivo do script não diz a causa; e as entradas que esperam por ela; depois, a entrada da linha next, que vem a seguir, ou, com next: none, que a corrente terminou sem entrada desbloqueada>

## O que ainda espera decisão

- <cada item como pergunta: o que destrava cada spec parada, cada PR aberto, cada contradição e cada gate manual aberto; a da parada técnica cita o ticket e o arquivo da pesquisa>?
````

## O fim

Com `next: none` no passo 1, a corrente terminou. Diga ao operador, pelo
relatório: as specs que fecharam, cada uma com o branch e o merge no branch base;
as que ficaram com PR aberto, com a URL; as que ficaram paradas, com o branch e o
motivo; as entradas paradas antes de nascer; e o caminho do relatório e o commit
dele.
Termine a vez oferecendo um grill novo, com a lista de "o que ainda espera decisão"
do relatório como pauta. A oferta é a última coisa da vez. Sem nenhuma entrada
tocada nesta execução, não há relatório novo: diga que nenhuma entrada estava
desbloqueada e ofereça o grill do mesmo jeito.

No bench, quem lê o chat não programa, e o relatório fica para quem opera o anvil.
A mensagem do fim é, no lugar dessa, a versão dele em português simples, que
termina a vez: o que cada parte pronta da ferramenta já deixa fazer, com o
endereço e o acesso da ferramenta, como na entrega do bench; o que ainda não dá
para fazer, pela parte que parou; e cada pergunta de "o que ainda espera decisão"
em linguagem de negócio. Sem log, comando, caminho de arquivo, id, nome de branch,
de commit ou de tecnologia. No lugar do grill novo, ofereça uma conversa nova
sobre essas perguntas, que volta à entrevista do bench.

Aceita a oferta, volte à entrada, no branch base, que edita o mesmo roteiro e
começa uma execução nova. Recusada, pare.

## Fora do caminho feliz

Poucos passos param a execução inteira, porque depois deles o estado que a
corrente leria não é confiável: uma recusa do `roadmap.sh`, o `new-spec.sh` que
falha, um `halt` do `frontier.sh`, caminho fora de commit quando a spec para ou
fecha, e a volta ao branch base que não sai. Nesse caso, não faça archive nem
merge, não contorne a guarda e não mexa no que ficou fora de commit. Termine a vez
dizendo ao operador a entrada, o passo, o motivo, o branch em que a execução
ficou e o que está commitado nele. No bench, diga isso primeiro em português
simples, pela parte da ferramenta que parou, e o detalhe técnico vai num bloco à
parte, para quem opera o anvil, como na entrega do bench chamado direto.

## Nunca

- Escrever arquivo, carregar o grill ou commitar antes de a largada passar.
- Commitar, criar branch ou rodar o `new-spec.sh` antes do sim, fora de uma
  retomada.
- Mostrar para confirmação um roteiro que o `roadmap.sh` recusa, ou que perdeu uma
  entrada inacabada sem o abandono explícito dela.
- Tirar uma entrada inacabada do roteiro sem a resposta do operador sobre ela.
- Escrever `Spec:` fora do passo que abre a spec da entrada, ou mudar o nome ou o
  `Spec:` de uma entrada que fica.
- Editar o `Entra:`, o `Fica de fora:` ou o `Pronto quando:` de uma entrada, nem
  para adaptar a uma contradição.
- Usar um anexo de fora do repositório antes de ele estar em `docs/discovery/`.
- Guardar, commitar ou descartar o que o operador deixou fora de commit na largada.
- Ligar o modo bench por outro sinal que não a rule da stack do bench ou o
  `--bench`, ou carregar o `anvil-bench` fora dele.
- No bench, mostrar no chat o `roadmap.md`, log, comando, caminho de arquivo, id
  ou nome de tecnologia, fora do bloco para quem opera o anvil numa parada da
  execução inteira.
- Marcar um gate manual, ou deixar commitada uma mudança no ledger de uma spec
  arquivada.
- Perguntar ao operador entre o sim, ou a largada de uma retomada, e o fim, ou ler
  o `anvil-next` dentro da execução.
- Começar uma entrada que não saiu no `next` do `roadmap.sh`.
- Fazer archive ou merge sem `PASS`, ou contornar a guarda de merge.
- Concluir o merge preparado sem a conferência do merge saindo `0`.
- Pesquisar numa parada por decisão, ou deixar uma spec parada por motivo técnico
  sem a pesquisa dela.
- Abrir rodada extra sem ticket apontado, sem evidência nova, com dois sinais de
  laço, ou num ticket que já tem a linha `- Piloto · rodada`.
- Resolver conflito de merge fora do `docs/index.md`, ou fazer o merge de um PR.
- Trocar de branch fora dos passos da corrente: a volta ao branch base depois do
  `new-spec.sh`, o `git checkout -B` do branch recém-criado, a ida ao branch base
  para o merge e a volta ao branch base depois de uma parada ou do PR aberto.
