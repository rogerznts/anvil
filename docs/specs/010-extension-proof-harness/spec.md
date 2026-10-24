# 010 — Helper de prova e sobras da 009

**Status:** ready-for-agent

Primeira de um roteiro de duas specs combinado no grill de 2026-10-23. Esta põe as
provas do toolkit sobre uma base que mede o que diz, como decide o ADR-0017 do
anvil — a prova roda pelo `/skill:` real, isolada, e sai inválida quando outro
modelo responde —, e fecha o que a spec 009
(`docs/specs/archive/009-extension-anvil-auto-open-points/`) deixou aberto. A
seguinte, a 011, leva o branch base e o forge, pelo ADR-0015 — um branch base só,
declarado nas rules ou detectado — e pelo ADR-0016 — as skills de git servem Gitea
e GitHub com o nome do toolkit —, e prova o que muda com o helper daqui. Os ADRs
estão em `docs/architecture/adr/`.

Os termos **Prova**, **Prova inválida**, **Piloto automático**, **Roteiro** e
**Frontier** são os de `docs/architecture/context.md`. A 009 arquivada não muda.

## Problem Statement

As provas das specs 008 e 009 são sessões headless do omp em `workspace/`, fora do
git, e mediram menos do que diziam:

- **Outro modelo respondeu.** Quando a Anthropic devolvia `overloaded_error`, o omp
  trocava o `claude-sonnet-4-5` pelo `openai-codex/gpt-6.1-sol`. Três tickets da 008
  e o ticket 02 da 009 foram provados assim, e a revisão de um ticket da 008
  calibrou o piloto por uma prova que não usou o modelo pedido.
- **O `/skill:` nunca foi exercitado.** No `omp -p`, e no `--mode json`, o
  `/skill:anvil-auto` chega ao modelo como texto. Toda prova manda "leia
  `skill://anvil-auto`" à mão, e nenhuma passa pelo caminho que o operador digita.
- **Skills ligadas à mão.** O `anvil-bench`, o `anvil-stack-payload` e o
  `tea-open-pr` não estão no roster do `dev-link.sh`. Cada prova cria e apaga
  symlinks em `~/.claude/skills` e `~/.agents/skills`, que todas as sessões da
  máquina leem, ou para com "não está ligado". Na 008, o piloto não achou o
  `tea-open-pr` e parou sem PR.
- **`/tmp` de nome fixo.** De `anvil-46` a `anvil-58`, cada prova começa com
  `rm -rf` num diretório fixo; duas rodadas ao mesmo tempo se apagam.
- **Infra compartilhada ou nenhuma.** As provas do bench usaram o registro, o
  Postgres e o Redis dos projetos reais. Um registro vazio pode alocar um banco que
  já existe no servidor, e a prova passaria a usá-lo. A alternativa adotada na 009
  foi um `docker` falso que impede o app de subir: a verificação com o app rodando
  nunca foi provada.
- **Sem remoto.** Nenhuma fixture tem remoto, e o caminho do PR fica sem prova.

E a 009 fechou com pontos que fazem o piloto, o bench ou um contrato errar:

- **`decisions-log.md` sumido.** O relatório do piloto lê o `decisions-log.md` de
  cada spec do branch, pelo caminho de antes do archive. Numa spec fechada a pasta
  já foi para `docs/specs/archive/`, o `git show` falha, e o relatório diz
  "nenhum".
- **Gate manual e `CHECK:` caído juntos.** O `GATE.md` não diz qual vale. Pelo
  item do gate manual, a spec para sem pesquisa; pelo do `CHECK:`, ela pesquisa. O
  piloto pode parar sem olhar a regressão.
- **B1 sem vermelho.** A busca pela spec aberta, na fase 2 do bench, só tem prova
  verde: com o texto de antes, o modelo nunca caiu em *Evoluir uma ferramenta*, e
  a prova não reprova se alguém tirar a busca.
- **Manual.** O `anvil-omp` diz "saindo `0`, commita o merge", sem a exceção do
  bench, em que vale a saída do `PASS`.
- **Bloco sem cerca.** No script do comando de verificação, um bloco `bash` sem a
  cerca de fechamento vai até o fim do arquivo e roda o resto das rules como
  comando. O cabeçalho do script diz que o bloco vai até o título seguinte.

## Solution

- **Um helper de prova**, versionado com a ferramenta de manutenção do repositório,
  que toda prova nova usa: cria o diretório da execução, carrega as skills do
  payload na sessão sem tocar no diretório de usuário, desliga o fallback de modelo
  só nela, conduz a sessão pelo modo rpc do omp com o `/skill:` de verdade, confere
  o modelo de cada mensagem e sai inválida quando não é o pedido. Sob pedido, monta
  um remoto bare com `gh` e `tea` falsos e uma infra do bench isolada, que sobe a
  stack de verdade e sai no fim.
- **O `infra.sh` do bench ganha um prefixo de execução**, que separa o compose, a
  rede, o registro e os volumes da infra compartilhada, e uma derrubada que só vale
  com o prefixo.
- **As sobras da 009**: o relatório lê o `decisions-log.md` pelo caminho certo; o
  `CHECK:` caído vale antes do gate manual aberto; o B1 ganha o vermelho; o manual
  diz a saída que passa; o bloco sem cerca é recusado.

As provas antigas de `workspace/` não são reescritas.

## User Stories

### Prova inválida

1. Como mantenedor, quero que a prova confira o modelo de cada mensagem do
   assistente no jsonl, para saber que o comportamento medido é o do modelo pedido.
2. Como mantenedor, quero que a conferência cubra a sessão principal e as sessões
   de subagente que ela abriu, como a do `anvil-implementer`: a principal pelo
   modelo pedido, e cada subagente por um modelo só do começo ao fim, para pegar a
   troca de modelo sem invalidar o agente que tem modelo próprio por papel.
3. Como mantenedor, quero que a prova respondida por outro modelo saia com o código
   `3`, distinto de verde e de vermelho, para não confundir "o provedor caiu" com
   "o comportamento quebrou".
4. Como mantenedor, quero que a saída inválida diga os modelos que responderam e
   quantas mensagens cada um, para decidir entre repetir e declarar o limite.
5. Como mantenedor, quero que o vermelho medido antes da mudança passe pela mesma
   conferência, para que o par vermelho e verde seja do mesmo modelo.
6. Como mantenedor, quero que a sessão da prova rode com o fallback de modelo
   desligado só nela, para que a sobrecarga do provedor vire repetição no mesmo
   modelo, sem mudar o config que as outras sessões da máquina usam.

### Caminho real

7. Como mantenedor, quero que a prova abra a sessão pelo modo rpc do omp e mande o
   primeiro turno como `/skill:<nome> …`, para provar o caminho que o operador
   digita.
8. Como mantenedor, quero que a prova mande turnos seguintes na mesma sessão, cada
   um depois de o anterior terminar, para provar conversas como o "sim" sobre o
   roteiro no turno 2.
9. Como mantenedor, quero que a prova espere a sessão assentar, sem trabalho em
   segundo plano pendente, antes de conferir o disco, para não ler um estado no
   meio.
10. Como mantenedor, quero os frames do rpc e uma cópia do jsonl da sessão nas
    saídas da prova, para investigar uma falha sem repetir a sessão.
11. Como mantenedor, quero que uma sessão que termina em erro do provedor apareça
    como tal nas saídas, para não lê-la como comportamento do toolkit.

### Isolamento

12. Como mantenedor, quero um diretório por execução, criado com nome único, para
    rodar duas provas ao mesmo tempo sem uma apagar a outra.
13. Como mantenedor, quero que as skills do payload, inclusive as fora do roster do
    `dev-link.sh` e as da camada omp, sejam carregadas na sessão da prova a partir
    da árvore do repositório, para provar o código em edição sem ligar nada à mão.
14. Como mantenedor, quero que a prova não escreva em `~/.claude`, `~/.agents` nem
    no config de usuário do omp, para que outra sessão da máquina não veja nada da
    prova.
15. Como mantenedor, quero pedir um remoto bare local para a fixture, com o branch
    dela publicado, para provar caminhos que dependem de `git push` e de
    `git remote`.
16. Como mantenedor, quero pedir `gh` e `tea` falsos à frente do `PATH`, que gravam
    os argumentos e o diretório de cada chamada e respondem como no sucesso, com a
    URL do PR, para provar o caminho do PR sem servidor.
17. Como mantenedor, quero que o diretório da execução e tudo o que ele subiu saiam
    no fim, também quando a prova falha ou é interrompida, para não deixar resto na
    máquina.
18. Como mantenedor, quero que as saídas da prova fiquem no diretório dela em
    `workspace/`, fora do diretório temporário, para consultá-las depois da limpeza.

### Infra do bench isolada

19. Como mantenedor, quero que o `infra.sh` aceite um prefixo de execução que dá à
    infra um nome de compose, uma rede, um registro e volumes próprios, para que a
    prova suba Postgres e Redis sem tocar nos dos projetos reais.
20. Como mantenedor, quero que a alocação feita sob o prefixo diga a rede, e que o
    app do projeto entre nela, para que a stack da prova suba de verdade e a
    verificação rode com o app no ar.
21. Como operador, quero que o `infra.sh` sem prefixo continue igual, com a rede
    `anvil-net` e o registro em `~/projects/.anvil-infra/`, para que nenhum projeto
    existente mude.
22. Como operador, quero que a derrubada da infra recuse rodar sem prefixo, para
    que nenhuma prova, nem um engano, derrube a infra compartilhada.
23. Como mantenedor, quero que a porta do admin alocada sob o prefixo continue
    conferida contra as portas em uso na máquina, para que a prova não colida com
    um projeto real no ar.

### Sobras da 009

24. Como operador, quero que o relatório do piloto traga o `decisions-log.md` da
    spec cujo archive está commitado no branch, lido do caminho de depois do
    archive, para ver o que foi decidido sem humano em toda spec que fechou ou que
    parou no fechamento.
25. Como operador, quero que a spec parada antes do archive continue com o
    `decisions-log.md` lido do caminho de antes do archive, que é onde ele está.
26. Como operador do bench, quero que uma saída com gate manual aberto desta spec e
    gate com `CHECK:` caído siga o caminho do `CHECK:` caído, para que a regressão
    seja pesquisada e corrigida antes de a spec parar pela pergunta.
27. Como operador do bench, quero que, quando nenhum `CHECK:` cai e só o gate manual
    desta spec segue aberto, a spec pare por decisão com a pergunta dele, como
    hoje.
28. Como mantenedor, quero que o `anvil-auto` dispense a pesquisa só quando não há
    `CHECK:` caído, para que ele e o `GATE.md` digam a mesma regra.
29. Como operador, quero que o manual `anvil-omp` diga que a conferência do merge
    passa com `0` fora do bench e com a saída que vale o `PASS` no bench, para que o
    manual não descreva uma regra que o piloto não segue.
30. Como operador, quero que um bloco `bash` sem a cerca de fechamento na seção de
    `## Comando de verificação` seja recusado com o motivo, como as outras recusas
    do script, para que nada além do comando declarado rode.
31. Como mantenedor, quero que o cabeçalho do script diga que o bloco vai até a
    cerca de fechamento, para que a documentação não descreva outro limite.
32. Como mantenedor, quero que o B1 da busca pela spec aberta reprove com o texto da
    fase 2 de antes da 009, caindo em *Evoluir uma ferramenta*, para que a prova
    segure a busca se alguém a tirar.

### Decididas depois dos tickets

33. Como pessoa que usa o bench, quero que uma mudança pedida enquanto há spec
    aberta espere essa spec fechar, sem entrevista nesta vez, e que a entrega diga
    que ela fica para depois, para que o bench termine o que começou antes de abrir
    outra frente.
34. Como mantenedor, quero que a prova declare as skills que o payload chama por
    `~/.claude/skills/<skill>/…` e que o helper recuse com `2` quando alguma não é
    um link para o payload desta árvore, para que a sessão nunca rode a cópia de
    outro projeto ou um script velho.

## Implementation Decisions

### O helper de prova

- **Onde mora.** Junto da ferramenta de manutenção do repositório, a
  `anvil-sync`, que não vai no degit nem na instalação de usuário. Ele não varia
  por projeto: a fixture de cada prova continua em `workspace/`.
- **Forma.** Uma biblioteca de shell que o script da prova carrega, com as
  operações abaixo, e um condutor da sessão rpc. A conferência dos fatos da prova
  continua no script da prova, como em `workspace/43-roadmap-state/s1.sh`. Sem
  dependência de pacote nova além do que as provas já usam.
- **Preparar.** Cria o diretório da execução com nome único e escreve nele o
  overlay de config do omp: `skills.customDirectories` com os diretórios de skill
  do payload e da camada omp do repositório, e `retry.modelFallback: false`. Uma
  skill de diretório customizado tem precedência sobre a de mesmo nome da
  instalação de usuário, então a sessão roda o payload em edição. Opções:
  - **remoto:** um repositório bare dentro do diretório da execução, adicionado
    como `origin` da fixture, com o branch dela publicado;
  - **forge falso:** um `gh` e um `tea` à frente do `PATH` da sessão. Cada chamada
    grava argumentos e diretório num log da execução. O `gh pr create` imprime uma
    URL de PR no stdout; o `tea pr create --output json` imprime o objeto com
    `index`, `title`, `url`, `state`, `base` e `head`. As outras chamadas saem `0`
    sem efeito;
  - **infra:** o prefixo de execução do `infra.sh`, com o id da execução.
- **Conduzir.** Abre o omp em modo rpc, com o overlay, o modelo pedido e o
  diretório da fixture. Manda cada turno como frame `prompt` e espera o
  `prompt_result` dele antes do seguinte; depois do último, espera o
  `session_settled`. Pelo `get_state`, guarda o `sessionFile`; pelos frames,
  as sessões de subagente. Grava os frames e as cópias dos jsonl nas saídas da
  prova.
- **Conferir o modelo.** Lê toda mensagem do assistente nos jsonl da sessão
  principal e dos subagentes. A principal com mensagem de modelo diferente do
  pedido, ou um subagente com mais de um modelo, torna a prova inválida; o
  subagente com modelo próprio por papel, do começo ao fim, só vai para o
  relatório. Sessão que terminou em erro do provedor fica registrada como tal.
- **Dependências declaradas.** A prova lista as skills que o payload chama pelo
  caminho da instalação de usuário, como `anvil-bench` e `anvil-stack-payload`. O
  helper confere que `~/.claude/skills/<skill>` é um link para o payload desta
  árvore e, se não for, sai `2` mandando rodar o `dev-link.sh`. O helper não liga
  nada.
- **Códigos de saída do helper:** `0` verde, `1` vermelho, `2` ambiente ou uso
  recusado (omp, docker ou git ausente, opção inválida, dependência não ligada,
  falha do próprio veredito), `3` inválida. A inválida vale sobre o vermelho e
  sobre o verde: com outro modelo, nenhum dos dois conta.
- **Limpar.** Num trap de saída, também em falha e interrupção: derruba a infra do
  prefixo, se houver, e remove o diretório da execução. As saídas ficam em
  `workspace/`.

### O prefixo de infra do bench

- Uma variável de ambiente nova do `infra.sh`. Com ela, o nome do projeto do
  compose, o nome da rede e o diretório do registro levam o prefixo, e os volumes
  ficam no projeto do compose prefixado. Sem ela, nada muda.
- A alocação ganha a rede entre as linhas que o `infra.sh` imprime, e o compose do
  app do starter lê o nome da rede do `.env`, com `anvil-net` como padrão. O bench
  materializa a rede no `.env` como já faz com o resto da alocação. Projeto sem a
  variável no `.env` continua na `anvil-net`.
- Uma operação de derrubada que remove o compose do prefixo com os volumes, a rede
  e o registro dele. Sem prefixo, ela recusa com o motivo e não toca em nada.
- A conferência de porta em uso na máquina continua valendo sob o prefixo.
- O `INVARIANTS.md` do bench passa a citar o prefixo como a única exceção à infra
  única por máquina, e só para prova.

### Sobras da 009

- **`decisions-log.md` no relatório.** O piloto lê o arquivo do branch da spec pelo
  caminho que ela tem lá: em `docs/specs/archive/<pasta>/` quando o archive está
  commitado no branch, o que vale para a spec fechada e para a parada no
  fechamento, e em `docs/specs/<pasta>/` quando ela parou antes do archive.
- **Precedência no `GATE.md`**, em "Sob o piloto automático": a saída com algum
  gate de `CHECK:` caído, nesta spec ou numa fechada, segue o caminho do `CHECK:`
  caído, haja ou não gate manual desta spec aberto. Só quando nenhum `CHECK:` cai,
  o gate manual aberto desta spec deixa a spec parada por decisão. A pergunta do
  gate manual vai para o relatório nos dois casos. O `anvil-auto` dispensa a
  pesquisa só quando nenhum `CHECK:` caiu, e aponta para o `GATE.md` em vez de
  repetir a regra.
- **Manual `anvil-omp`.** A frase da conferência do merge passa a dizer a saída que
  passa: `0` fora do bench, a que vale o `PASS` pela regra do `GATE.md` no bench.
- **Script do comando de verificação.** O bloco vai da cerca de abertura `bash` até
  a cerca de fechamento. Sem a cerca de fechamento, as duas operações recusam com
  uma linha `refusal:` e saída `2`, e nada roda. O cabeçalho do script diz o limite
  novo.
- **B1.** O caso R ganha o vermelho medido com o texto da fase 2 do `anvil-bench`
  de antes da 009. A fixture e o pedido do turno são ajustados até o texto antigo
  cair em *Evoluir uma ferramenta*; o texto de hoje segue para a construção da
  spec aberta.
- **Mudança pedida com spec aberta, no bench.** Decisão do operador depois do
  ticket 09: com spec aberta, a mudança que o usuário pede espera, sem entrevista
  nesta vez; o bench segue a construção da spec aberta, e a entrega diz que a
  mudança fica para depois que ela fechar. *Evoluir uma ferramenta* abre dizendo
  que só vale sem spec aberta, e a busca pela spec aberta lista os tickets não
  `resolved` por um comando. Sem isso, o texto da 009 ia à entrevista e não
  construía.

## Testing Decisions

Um bom teste observa o que o operador ou o mantenedor veria: códigos de saída,
linhas impressas, arquivos e commits na fixture, o log do forge falso, containers e
redes que existem ou não, o relatório. Nunca o texto de uma skill.

Toda prova nova vai num diretório novo de `workspace/`, a partir do próximo número
livre, e as de S2 e B1 rodam pelo helper.

### S1 — o helper sem modelo (novo)

Bash puro, sem sessão de agente, no bash do `PATH` e no `/bin/bash` 3.2 do macOS:

- duas execuções simultâneas recebem diretórios diferentes, e cada uma remove o seu
  no fim, também quando a prova sai com erro e quando recebe um sinal;
- o overlay traz o fallback desligado e os diretórios de skill do payload e da
  camada; nada é escrito em `~/.claude`, `~/.agents` nem no config de usuário do
  omp, conferido pelo antes e depois;
- o remoto bare recebe o push da fixture, e `git remote` o mostra;
- o `gh` e o `tea` falsos estão à frente do `PATH`, gravam a chamada e imprimem a
  URL no formato de cada um;
- a conferência do modelo sobre jsonl de fixture: todas as mensagens do modelo
  pedido dá verde; uma mensagem de outro modelo, na sessão principal ou num
  subagente, dá `3`, com os modelos e as contagens;
- com docker: o prefixo cria um compose, uma rede e um registro separados dos da
  infra compartilhada, que ficam como estavam; a derrubada os remove; a derrubada
  sem prefixo recusa e não toca na infra compartilhada.

### S1 — script do comando de verificação (existente)

Prior art: `workspace/53-verification-command/`. Caso novo: bloco sem a cerca de
fechamento, seguido de mais seções nas rules, dá `refusal:` e saída `2` nas duas
operações, e o comando não roda.

### S2 — sessão do piloto pelo helper (novo formato)

Prior art: o caso F de `workspace/56-manual-gate-rule/` e as fixtures de
`workspace/51-auto-bench/` e `workspace/57-merge-check/`. O primeiro turno é
`/skill:anvil-auto`, pelo rpc. Casos:

- **Spec fechada com decisões.** O relatório traz o `decisions-log.md` da spec
  arquivada, e não "nenhum".
- **Saída mista.** Gate manual desta spec aberto e gate de `CHECK:` caído: o piloto
  segue o caminho do `CHECK:` caído, com pesquisa, e só depois para pela pergunta
  do gate manual. O vermelho, com o texto de antes, para sem pesquisar.

### B1 — o bench pelo helper, com infra isolada (existente, ampliado)

Prior art: `workspace/58-bench-profiles/`. Sem `docker` falso: a stack sobe sob o
prefixo e sai no fim. Os casos N, R e E da 009, com o caso R ganhando o vermelho
descrito acima. A infra compartilhada fica como estava, conferida pelo antes e
depois dos containers, redes e registro.

### Prova inválida nas provas

Toda S2 e B1 desta spec reporta o código do helper. Prova inválida se repete; se
persistir, o ticket declara o limite com os modelos que responderam, e o ticket não
se fecha com um verde inválido.

### S3 — `vendor-sync.sh verify` (existente)

Sai `0`.

## Out of Scope

- **O branch base e o forge**: a resolução do branch, a seção `## Git`, as skills
  `anvil-*` no lugar das `tea-*`, o `gh`, o alias de ssh, as mensagens da guarda e o
  `dev-link.sh` que tira links de skill que saiu. São a 011.
- **A prova da conferência da árvore no caminho do PR**, o P2 do ticket 04 da 009.
  Vai para a 011, com a skill neutra, usando o remoto bare e o forge falso daqui.
- **Reescrever as provas antigas** de `workspace/` para o helper.
- **O passo 1 de *Uma entrada do roteiro* sem roteiro**, o segundo P2 do ticket 07
  da 009, que o caso R não exercita: fica como lacuna de prova.
- **As saídas sem desfecho no `GATE.md`** além da mista, como o `HANDOFF REQUIRED`
  de um gate abandonado, que o bench não escreve.
- **Todos os P3 da 009.** Ficam no `## Comments` dos tickets arquivados.

## Further Notes

- O remoto bare e o forge falso nascem aqui com prova só no S1; o primeiro
  consumidor deles é a 011.
- A conferência do modelo lê o jsonl, e não o `get_state`, porque o modelo pode
  mudar no meio da sessão; o `get_state` serve só para achar o arquivo.
- O fallback desligado faz uma sobrecarga longa do provedor virar uma sessão lenta
  ou em erro, e não uma troca de modelo. A conferência do jsonl continua como
  defesa para quando o omp mudar o nome ou o padrão dessa config.
