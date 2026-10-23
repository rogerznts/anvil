# 009 — Pontos em aberto do piloto automático

**Status:** ready-for-agent

Extensão da spec 008 (`docs/specs/archive/008-feature-anvil-auto/`), que está
arquivada e não muda. Esta spec fecha o que os tickets da 008 deixaram aberto no
`## Comments`: as cinco decisões que esperavam o operador e os P2 que mudam
comportamento ou fazem um contrato mentir. O critério de corte é o de
`docs/agents/verification.md`: o que é só lacuna de prova, duplicação sem
divergência ou forma (os demais P2 e todos os P3) fica como linha do tracker,
listada em Out of Scope.

Os termos **Piloto automático**, **Roteiro**, **Condutor** e **Frontier** são os
de `docs/architecture/context.md`. O ADR-0010 do anvil, que fecha a verificação
em duas rodadas com a terceira como escolha declarada, e o ADR-0014, que dá ao
piloto automático o roteiro do grill ao fechamento sem humano, valem como estão.

## Problem Statement

O piloto automático, a skill `anvil-auto`, e o bench, a skill `anvil-bench`,
foram entregues na 008 com pontos que o operador ainda não tinha decidido e com
caminhos que, seguidos ao pé da letra, fazem o contrário do que a spec promete:

- **Roteiro.** Um nome de entrada com espaço ou maiúscula passa pelo
  `roadmap.sh`, e depois quebra o `frontier:`, o `--skip` e o `--short-name` do
  `new-spec.sh`. Uma spec arquivada no branch e ainda sem merge sai com o motivo
  "espera o merge do PR", também num projeto que fecha por merge local, e esse
  texto vai para o índice e para o relatório.
- **Despacho.** O laço do piloto anota o ticket pulado, mas volta ao começo com a
  saída de antes, cujo `next` ainda aponta o pulado: lido ao pé da letra, o piloto
  despacha o mesmo ticket de novo.
- **Comando de verificação.** O piloto extrai o bloco de
  `## Comando de verificação` com um `awk` dentro de `bash -c "$(…)"`, copiado na
  largada e no `PASS`. Em duas de cinco rodadas do S2 da 008, o modelo errou o
  escape, a extração falhou, e ele digitou o comando à mão: o `PASS` rodou algo
  que não é necessariamente o que o projeto declarou.
- **Árvore suja na `main`.** A "Parada" confere a árvore antes de voltar à `main`;
  o fechamento por PR e o merge local de sucesso, não. O que o `tea-open-pr` ou o
  archive deixar fora de commit vai para a `main` com o piloto.
- **Rascunho da contradição.** Uma contradição incumprível achada enquanto o
  piloto escreve a spec ou os tickets deixa o rascunho fora de commit. A "Parada"
  exige árvore limpa, e a execução inteira para, em vez de só a spec.
- **Spec irmã fechada na `main`.** O `PASS` roda no branch da spec. Uma spec que
  fechou na `main` depois que o branch foi cortado não está nesse checkout: fora
  do bench, o comando de verificação não roda sobre o código dela; no bench, o
  `--reverify` não reexecuta o ledger dela. O merge pode quebrar o que já foi
  entregue sem nada que segure o fechamento.
- **Gate manual.** O `GATE.md` diz que todo gate manual aberto deixa a spec
  parada; o `anvil-auto` diz que o de uma spec já fechada não segura esta. O
  piloto lê os dois e recebe duas regras para o mesmo caso.
- **Bench sem o perfil do tracker.** O `SKILL.md` do bench aponta para
  `docs/agents/issue-tracker.md` do projeto, e um projeto novo do bench não tem o
  arquivo: nem o starter o traz, nem algum passo o cria.
- **Retomada do bench.** A retomada de uma construção começada fora do bench
  commita o `docs/qa/checklist.yaml` no branch da spec. Reativado ali, o bench vê
  o checklist, cai em *Evoluir uma ferramenta*, e os tickets abertos ficam sem
  construção. Sem roteiro, o `roadmap.sh` dá `next: none`, e o passo 1 de *Uma
  entrada do roteiro* manda não construir nada, contra a retomada.
- **Teto rival.** O `unlazy/VENDOR.md` ainda diz "teto de três tentativas por
  ticket", e o `GATE.md` linka para ele: quem segue o link lê um teto que não é o
  das duas rodadas.
- **Manual.** O `anvil-omp` diz que o `/anvil-bench` chamado direto constrói "a
  primeira entrada do roteiro" e lista o archive e o merge "no relatório". O
  bench constrói a entrada em andamento ou a do `next:`, e a lista sai na entrega.
- **Decisões sem registro.** Na 008, o implementer passou a executar a rodada
  extra do piloto, o bench chamado direto passou a gravar o `Spec:` e o índice
  deixa sem link a spec que só existe no branch dela. As três são o
  comportamento de hoje, e nenhum contrato as registra como decisão. O formato da
  linha do piloto também diverge: o piloto a grava com o caminho entre crases e
  um texto depois, e o implementer a lê como `aberta por <arquivo>`.

## Solution

Uma passada de correção nas peças da 008, sem peça nova além de um script do
piloto:

- o `roadmap.sh` recusa nome fora de kebab-case e dá um motivo neutro à spec
  arquivada sem merge;
- o piloto lê o comando de verificação por um script, roda o `frontier.sh` de
  novo com o `--skip` quando pula um ticket, confere a árvore antes de toda volta
  à `main`, commita o rascunho que fica parado e, quando a `main` andou, confere
  a verificação sobre o merge antes de commitá-lo;
- a regra do gate manual mora num lugar só, o `GATE.md`;
- o bench cria os perfis do tracker e de verificação num projeto novo e escolhe
  a retomada antes de *Evoluir* quando há spec aberta;
- o `VENDOR.md`, o manual `anvil-omp` e o perfil do tracker passam a dizer o que
  o código faz.

As cinco decisões do operador ficam registradas aqui:

| Ticket da 008 | Decisão |
|---|---|
| 01 | Nome de entrada fora de kebab-case é recusado pelo `roadmap.sh` |
| 02 | A entrada cuja spec só existe no branch dela sai no índice como `spec NNN`, sem link |
| 07 | O `anvil-implementer` executa a rodada extra que o piloto abre pela linha `- Piloto · rodada <N>`, e isso vira contrato do perfil do tracker |
| 08 | O teto de três sai do `unlazy/VENDOR.md` |
| 09 | O bench chamado direto também grava o `Spec:` da entrada |

## User Stories

### Roteiro

1. Como operador, quero que o `roadmap.sh` recuse um nome de entrada fora de
   kebab-case, com o nome e o formato esperado no motivo, para que o erro apareça
   antes de o piloto criar uma spec com ele.
2. Como operador, quero que a recusa por nome saia como as outras, numa linha
   `refusal:`, com saída `2` e sem frontier, para que o piloto, o bench e o índice
   a tratem sem caso novo.
3. Como operador, quero que um roteiro com vários nomes inválidos dê uma linha
   `refusal:` por nome, para corrigir todos de uma vez.
4. Como operador, quero que nomes como `a`, `cadastro-de-clientes` e
   `fase-2-relatorios` continuem válidos, para que o roteiro de hoje não passe a
   ser recusado.
5. Como operador, quero que a spec arquivada no branch e ainda sem merge saia com
   um motivo que não fale de PR, para que o índice e o relatório de um projeto sem
   PR não mintam.
6. Como operador de um projeto que fecha por PR, quero que o relatório continue
   dizendo que a entrada espera o merge do PR, para saber o que me cabe.
7. Como operador, quero que o formato do nome e a recusa estejam no perfil do
   tracker, para que quem escreve o roteiro à mão saiba a regra.

### Despacho

8. Como operador, quero que o piloto rode o `frontier.sh` de novo com o `--skip`
   assim que pula um ticket, para que o `next` nunca aponte um ticket já pulado.
9. Como operador, quero que um ticket pulado não seja despachado de novo na mesma
   execução, como na `anvil-run`, para que o piloto não gaste um implementer no
   que já terminou sem mudar o estado.

### Comando de verificação

10. Como operador, quero que o piloto leia o bloco de `## Comando de verificação`
    por um script, para que a largada e o `PASS` leiam o mesmo comando.
11. Como operador, quero que o script recuse, com o motivo, a rule sem a seção, a
    seção sem bloco `bash` e o bloco vazio, para que a largada recuse como hoje.
12. Como auditor, quero que o `PASS` rode o bloco pelo script, da raiz do projeto,
    e grave a saída e a linha `exit:`, para que o relatório mostre o comando
    declarado, e não o que o modelo digitou.
13. Como mantenedor, quero que o script seja instalado com o resto da camada omp,
    para que o piloto o ache na instalação de usuário.

### Árvore limpa e rascunho

14. Como operador, quero que o piloto confira a árvore antes de toda volta à
    `main` no fechamento, no PR e no merge local, para que nada fora de commit
    chegue à `main` com ele.
15. Como operador, quero que a árvore suja nesse ponto pare a execução, como diz
    "Fora do caminho feliz", com os arquivos no motivo, para decidir o que fazer
    com eles.
16. Como operador, quero que o rascunho da spec ou dos tickets, quando uma
    contradição incumprível para a spec, seja commitado no branch dela antes da
    parada, para que só a spec pare, e a corrente siga.
17. Como auditor, quero o commit do rascunho com uma mensagem que diga que a spec
    parou num rascunho, para que o log não o confunda com uma spec pronta.

### Spec irmã fechada na `main`

18. Como operador, quero que, quando a `main` tem commits que o branch da spec
    não tem, o piloto confira a verificação sobre o merge antes de commitá-lo,
    para que uma spec nova não quebre o que já foi entregue.
19. Como operador fora do bench, quero que essa conferência seja o bloco de
    `## Comando de verificação`, rodado pelo script sobre o estado combinado.
20. Como operador do bench, quero que essa conferência seja o `--reverify` dos
    ledgers desta spec e de cada spec do roteiro já `closed` na `main`, para que a
    irmã que fechou depois do corte também conte.
21. Como operador, quero que a conferência que falha aborte o merge e deixe a spec
    parada, já arquivada no branch, com a saída no relatório e a pergunta em "o que
    ainda espera decisão", para que o conflito entre duas specs fique com quem
    decide.
22. Como operador, quero que essa parada não abra pesquisa nem rodada extra, como
    o merge abortado por conflito, porque a spec já está arquivada e o problema
    está entre duas specs.
23. Como operador, quero que, sem commit novo na `main`, o merge siga como hoje,
    sem rodar a verificação de novo, porque o `PASS` já rodou sobre a mesma árvore.
24. Como operador, quero que a conferência passe pela guarda de merge como o
    merge de hoje, sem contorno, para que a guarda continue valendo para o piloto.
25. Como operador de um projeto que fecha por PR, quero que nada mude no caminho
    do PR, porque a revisão do PR é minha.

### Gate manual

26. Como operador do bench, quero uma regra só para o gate manual aberto sob o
    piloto, no `GATE.md`: o gate manual desta spec deixa a spec parada; o de uma
    spec fechada vai para "o que ainda espera decisão" e não segura esta.
27. Como mantenedor, quero que o `anvil-auto` e o `SKILL.md` do bench apontem para
    essa regra em vez de repeti-la, para que a próxima mudança seja num lugar só.

### Bench

28. Como pessoa que não programa, quero que o projeto novo do bench nasça com o
    perfil do tracker e o de verificação, para que as skills de fluxo achem os
    arquivos que o bench cita.
29. Como operador do bench, quero que os dois perfis venham dos templates do
    `anvil-docs`, sem sobrescrever um perfil que o projeto já tem, como no
    `scaffold`.
30. Como operador do bench, quero que uma spec aberta, fora de
    `docs/specs/archive/`, com ticket ainda não `resolved`, seja retomada antes de
    qualquer outro ramo da fase 2, para que a reativação no meio da retomada não
    caia em *Evoluir*.
31. Como operador do bench, quero que, sem roteiro, *Uma entrada do roteiro*
    construa a spec aberta em vez de parar no `next: none`, para que a retomada sem
    roteiro chegue ao fim.
32. Como operador do bench, quero que *Evoluir uma ferramenta* continue valendo
    para a ferramenta sem spec aberta, para que o delta pedido siga o caminho de
    hoje.
33. Como mantenedor, quero que o `unlazy/VENDOR.md` diga o teto das duas rodadas,
    para que o link do `GATE.md` não leve a um teto rival.

### Contratos

34. Como operador, quero que o perfil do tracker, nas duas cópias, descreva a
    linha `- Piloto · rodada <N> aberta por …` que abre a rodada extra, com quem a
    escreve e o que o implementer faz com ela, para que a exceção ao ADR-0010 do
    anvil esteja no contrato, e não só no agente.
35. Como operador, quero que o piloto escreva e o implementer leia a linha do
    piloto no mesmo formato, para que a rodada extra não dependa de o modelo
    tolerar a diferença.
36. Como operador, quero que o manual `anvil-omp` diga que o `/anvil-bench`
    chamado direto constrói a entrada em andamento, ou a do `next:`, e que o
    archive e o merge saem listados na entrega, para que eu não espere o
    contrário.
37. Como operador, quero o registro desta spec de que o bench chamado direto grava
    o `Spec:` e de que a spec só no branch sai sem link no índice, para que a frase
    da spec 008 não pareça a regra vigente.

## Implementation Decisions

### `roadmap.sh`

- **Nome.** Uma entrada cujo nome não casa com o kebab-case, letras minúsculas
  ASCII e dígitos em grupos separados por um hífen, sem hífen no começo nem no fim,
  gera uma linha `refusal:` com o nome entre aspas simples e o formato esperado.
  Entra na mesma lista das recusas de hoje, uma linha por nome, saída `2`, sem
  frontier. O cabeçalho do script passa a listar a recusa.
- **Motivo neutro.** A spec arquivada no branch e ainda sem merge na `main` sai
  `stopped` com o motivo "arquivada no branch <branch> e ainda sem merge na main".
  O estado não muda; só o texto. O script não sabe se o projeto fecha por PR, e não
  passa a saber.
- O piloto, no relatório, continua dando a causa: PR aberto, merge abortado por
  conflito ou verificação que falhou sobre o estado combinado. O índice mostra o
  motivo neutro.

### Script do comando de verificação

- **Peça nova:** um script na pasta do `anvil-auto` na camada omp, instalado como
  os outros arquivos da camada. Duas operações:
  - conferir: imprime o comando do bloco e sai `0`; sem a seção, sem bloco `bash`
    dentro dela ou com bloco vazio, sai diferente de `0` com o motivo numa linha;
  - rodar: roda o bloco da raiz do projeto, com a saída do comando e uma última
    linha `exit: <código>`.
- A seção é a de `.claude/rules/anvil.md`, sob o título exato
  `## Comando de verificação`, a que o `anvil-boot` grava. O título não muda.
- A largada usa conferir; o `PASS` e a conferência do merge usam rodar. O `awk`
  inline sai das duas seções do `anvil-auto`.

### Laço de despacho do piloto

- O passo de comparar o ticket despachado ganha o que o passo 5 da `anvil-run` já
  tem: com pulado novo, o piloto roda o `frontier.sh` mais uma vez, já com o
  `--skip`, e volta ao começo com essa saída.
- O `frontier.sh` e a `anvil-run` não mudam.

### Fechamento

- **Árvore limpa.** Antes de todo `git checkout main` do fechamento, depois do
  commit do archive e, no PR, depois do push da linha `PR:`, o piloto confere
  `git status --porcelain`. Com linha na saída, a execução para, como diz "Fora do
  caminho feliz", com os arquivos no motivo.
- **Rascunho parado.** Quando uma contradição incumprível para a spec antes de os
  tickets estarem completos, o que o piloto escreveu na pasta da spec é commitado
  no branch, com uma mensagem em inglês que diz que a spec parou num rascunho, e só
  então vale a "Parada". Só a pasta da spec entra no commit.
- **Conferência do merge.** No merge local, antes de mesclar, o piloto confere se a
  `main` tem commits que o branch não tem. Sem, o merge é o de hoje. Com, o merge
  sai com `--no-ff --no-commit`:
  1. conflito só no `docs/index.md` se resolve como hoje, antes da conferência; outro
     conflito aborta, como hoje;
  2. com o merge preparado, o piloto roda a verificação sobre o estado combinado:
     fora do bench, o script do comando; no bench, o `--reverify` do `GATE.md`, com o
     ledger desta spec, agora em `docs/specs/archive/`, e os das specs `closed`;
  3. com a saída que passa — fora do bench, `0`; no bench, a que vale o `PASS` pela
     regra de "Sob o piloto automático" do `GATE.md`, porque um gate manual aberto de
     uma spec fechada dá `exit: 1` e não segura esta —, o piloto commita o merge,
     com a mensagem padrão;
  4. com qualquer outra saída, o piloto devolve os ledgers que o checker reescreveu,
     aborta o merge com `git merge --abort`, e a spec fica parada, já arquivada no
     branch. É parada por decisão: sem pesquisa e sem rodada extra. O relatório leva
     a saída, e "o que ainda espera decisão" leva a pergunta de qual spec cede.
- O `git merge --no-ff --no-commit` é conferido pela guarda como o merge de hoje, e
  passa, porque a spec já está arquivada no branch. O commit que conclui o merge não
  é verbo de merge e não é reconferido.
- O caminho do PR não muda.

### Gate manual

- A regra fica no `GATE.md`, seção "Sob o piloto automático": gate manual aberto
  no ledger desta spec deixa a spec parada e vai para o relatório como pergunta;
  gate manual aberto no ledger de uma spec fechada vai para "o que ainda espera
  decisão" e não segura esta; sem gate manual desta spec aberto e sem gate com
  `CHECK:` caído, a saída vale o `PASS`.
- O `anvil-auto` e a seção "Sob o piloto automático" do `SKILL.md` do bench
  apontam para essa regra. O `anvil-auto` guarda só o que o piloto faz com cada
  desfecho: parar, registrar no relatório, seguir.

### Bench

- **Perfis no projeto novo.** No passo de projeto novo da fase 2, o bench instala
  `docs/agents/issue-tracker.md` e `docs/agents/verification.md` a partir dos
  templates do `anvil-docs`, com a regra do `scaffold`: ausente, copia; idêntico,
  segue; divergente, não sobrescreve. Sob o piloto, entram no commit do piloto
  depois do sim; chamado direto, no primeiro commit.
- **Ordem dos ramos da fase 2.** Antes dos ramos de hoje, o bench procura uma spec
  aberta, fora de `docs/specs/archive/`, com ticket não `resolved`. Achou, a
  construção segue por ela: a fase 4, se falta o `gates.md`; senão, a fase 5 pelos
  tickets não `resolved`. *Evoluir uma ferramenta* só vale sem essa spec.
- **Passo 1 de *Uma entrada do roteiro*.** Com `roadmap: none` e uma spec aberta, a
  entrada é essa spec. O `next: none` só segura a construção quando há roteiro.
- **`unlazy/VENDOR.md`.** O "teto de três tentativas por ticket" vira o teto das
  duas rodadas do `GATE.md`. O arquivo é do anvil, no `keep` do manifesto, e a
  edição é permitida. Os scripts e o resto do `unlazy/` não mudam.

### Contratos e documentação

- **Perfil do tracker, nas duas cópias** (o template do `anvil-docs` e
  `docs/agents/issue-tracker.md`, que ficam idênticos):
  - a seção do roteiro diz o formato do nome e que o `roadmap.sh` o recusa;
  - a seção de `Review:` descreve a linha `- Piloto · rodada <N> aberta por …`: só
    o piloto automático a escreve, uma vez por ticket, no fim do `## Comments`, e o
    `anvil-implementer` mede a rodada N quando nenhuma `Review:` tem `round=<N>`.
- **Formato da linha do piloto.** Um formato só, o que o piloto já grava: caminho
  do arquivo entre crases, dois-pontos, a fonte e o que ela explica. O
  implementer passa a citar esse formato. A regra de decisão dele não muda.
- **Manual `anvil-omp`.** O parágrafo do `/anvil-bench` chamado direto, em "O que
  continua manual", diz a entrada em andamento ou a do `next:` e a lista do
  fechamento na entrega.
- **`docs/specs/README.md`**, se cita as recusas do roteiro, ganha a do nome.
- A spec 008 arquivada não muda. As decisões dos tickets 02 e 09 ficam
  registradas nesta spec. O `INDEX.md` e o perfil do tracker já dizem o
  comportamento decidido.

## Testing Decisions

Um bom teste observa o que o operador veria: linhas do `roadmap.sh`, a saída do
script de verificação, arquivos e commits na `main` e nos branches, um merge feito
ou abortado, a linha do relatório. Nunca o texto de uma skill.

### S1 — `roadmap.sh` sobre repositórios de fixture (existente)

Prior art: `workspace/43-roadmap-state/s1.sh`. Bash puro, no bash do `PATH` e no
`/bin/bash` 3.2 do macOS, com saídas iguais. Casos novos:

- nomes válidos (`a`, `cadastro-de-clientes`, `fase-2-relatorios`) sem recusa;
- nomes inválidos (com espaço, com maiúscula, com `_`, com hífen no começo, com
  hífen duplo), uma `refusal:` por nome e saída `2`;
- spec arquivada num branch local e sem merge: `stopped`, com o motivo neutro,
  sem "PR".

### S2 — sessão headless do omp com `/skill:anvil-auto` (existente)

Prior art: `workspace/47-auto-chain/`, `workspace/48-auto-stops/` e
`workspace/51-auto-bench/`, com `omp -p --mode json`. Casos novos:

- **Pulado.** Um ticket que o implementer termina sem mudar o estado: a sessão
  despacha o ticket uma vez só, e o `frontier.sh` roda com o `--skip` antes do
  despacho seguinte.
- **Comando declarado.** Um bloco de verificação com aspas e `$` dentro: a saída
  gravada no relatório é a do comando declarado, e o `exit:` vem do script.
- **Árvore suja no fechamento.** Um hook que deixa arquivo fora de commit depois
  do archive: a execução para antes de voltar à `main`, e a `main` não recebe o
  arquivo.
- **Rascunho parado.** Uma entrada cuja contradição incumprível aparece ao escrever
  os tickets: o rascunho fica commitado no branch, a spec para, e a entrada
  independente fecha.
- **Irmã na `main`, verde.** Duas entradas independentes; a segunda fecha na `main`
  depois do corte da primeira, e a verificação passa sobre o merge: o merge sai
  commitado.
- **Irmã na `main`, vermelha.** A mesma forma, com a primeira quebrando o que a
  segunda entregou: o merge é abortado, a `main` fica como estava, a spec fica
  arquivada no branch e parada, sem pesquisa.

Fora do bench, os dois casos de irmã usam o comando de verificação. No bench, a
prova é o caso de `workspace/51-auto-bench/` com o `--reverify` da irmã, se o
custo da stack couber; senão, o limite fica declarado no ticket.

O S2 registra o modelo que de fato respondeu, lido do jsonl.

### B1 — um turno headless do bench (novo)

Um turno do `/anvil-bench` sobre projetos de fixture, sem subir o app, só para ver
o ramo da fase 2:

- projeto novo: o primeiro commit traz `docs/agents/issue-tracker.md` e
  `docs/agents/verification.md`, iguais aos templates;
- projeto com spec aberta, tickets não `resolved` e `docs/qa/checklist.yaml` no
  branch, sem roteiro: o bench segue a retomada, e não *Evoluir*;
- ferramenta sem spec aberta, com mudança pedida: o bench segue *Evoluir*.

### S3 — `vendor-sync.sh verify` (existente)

Sai `0` com o script novo na camada, e o check 15, sobre os caminhos citados pela
camada omp, passa com o script citado pelo `anvil-auto`.

## Out of Scope

- **Os demais P2 da 008, que são lacuna de prova**, e não defeito: o caso I do S2
  do ticket 04, a regra do bloco custom do índice sem prova, o bloqueio da guarda
  sem caso, a contradição depois de a spec nascer e a decisão aberta do `map.md`
  sem caso, as três paradas técnicas e o gate manual marcados sem prova executada,
  a condição 4 da rodada extra sem caso próprio, o caminho do boot que grava o
  resto do `anvil.md` sem a seção.
- **A cópia marcada de um lado só** entre o `roadmap.sh`, o `frontier.sh` e o
  `new-spec.sh`. Ela não diverge hoje.
- **As outras duplicações sem divergência**: o exemplo do roteiro repetido no
  piloto e no bench, o "Abrir a spec" do bench e do piloto, a regra do
  `Cobre:`, o título `## Comando de verificação` citado em quatro lugares, a lista
  das peças da camada omp em cinco lugares.
- **Todos os P3 da 008.** Ficam no `## Comments` dos tickets arquivados.
- **O check 15 sobre caminhos com `~/`**, que vem da 006.
- **Paralelo no piloto**, como na 008.
- O `docs/project/plan.md` e o ADR-0003, que ficam com o teto de três por serem
  histórico.

## Further Notes

- A conferência do merge é a única mudança de comportamento que o operador nota no
  caminho feliz, e só quando a `main` andou durante a spec: o merge leva o tempo de
  mais uma verificação.
- A spec arquivada no branch e parada pela conferência do merge sai no índice como
  `stopped`, com o motivo neutro. O piloto não a retoma nem refaz o merge dela
  sozinho: a decisão de qual spec cede é do operador, e é o que o relatório
  pergunta. O ticket da conferência do merge confere o que a retomada do piloto
  faz no branch de uma spec já arquivada e, se for preciso, a faz recusar com
  esse motivo.
