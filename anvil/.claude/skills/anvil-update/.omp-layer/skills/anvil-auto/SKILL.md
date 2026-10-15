---
name: anvil-auto
description: Piloto automático do anvil no omp. Recusa a largada indevida, conduz o grill sobre o plano inteiro de várias specs, escreve o roteiro em docs/specs/roadmap.md, valida pelo roadmap.sh e o commita na main com o único sim do operador.
argument-hint: "o pedido, que vai para o grill"
disable-model-invocation: true
---

# Piloto automático

O operador chamou esta skill com um pedido que pode ocupar várias specs. Você é o
piloto. Ele participa uma vez só: no grill, que cobre o plano inteiro e termina no
**roteiro** escrito em `docs/specs/roadmap.md`. A confirmação dele sobre o roteiro
escrito é o único sim da execução. Carregar uma skill é lê-la com o `read` em
`skill://<nome>` e segui-la.

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

Rode o `roadmap.sh` mais uma vez e termine a vez com a frase "O roteiro está
pronto", seguida do commit na `main` e da entrada da linha `next`.

## Nunca

- Escrever arquivo, carregar o grill ou commitar antes de a largada passar.
- Commitar, criar branch ou rodar o `new-spec.sh` antes do sim.
- Mostrar para confirmação um roteiro que o `roadmap.sh` recusa, ou que perdeu uma
  entrada inacabada sem o abandono explícito dela.
- Tirar uma entrada inacabada do roteiro sem a resposta do operador sobre ela.
- Escrever `Spec:` numa entrada, ou mudar o nome ou o `Spec:` de uma entrada que
  fica.
- Usar um anexo de fora do repositório antes de ele estar em `docs/discovery/`.
- Guardar, commitar ou descartar o que o operador deixou fora de commit na largada.
- Trocar de branch.
