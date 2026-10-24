---
name: anvil-omp
description: Manual da camada omp do anvil. O que ela instala em ~/.omp/agent/, como a detecção decide, os comandos, o piloto automático, a isolação, os limites e como removê-la.
argument-hint: "pergunta opcional sobre a camada"
disable-model-invocation: true
---

# Camada omp

Responda ao operador com o que está abaixo. Com pergunta nos argumentos, responda só
a ela. Sem pergunta, mostre um resumo curto de cada seção.

## O que é

O anvil roda em três harnesses: Claude Code, Codex e omp. Nos três as skills são as
mesmas, e só no omp o fluxo pode ser conduzido, porque o omp tem `task`, agentes
próprios e sessões filhas que nascem sem a conversa do pai.

A camada omp é o que o anvil instala em `~/.omp/agent/`, uma vez por usuário, para
isso: o hook que traz a guarda de merge para o omp, a rule que traduz o vocabulário
do Claude Code nas skills, a rule com as diretivas do anvil, o agente que
implementa um ticket, e as skills `anvil-plan`, `anvil-run`, `anvil-auto` e esta.
As skills do payload chegam ao omp pelo espelho `~/.agents/skills`. A lista exata
do que está instalado são as linhas `omp:` do `~/.claude/anvil.lock`, uma por
arquivo, com o caminho relativo a `~/.omp/agent/`.

## Como a detecção decide

O reset da instalação de usuário instala a camada, sem pergunta à parte, quando
acha um destes sinais:

- o binário `omp` no `PATH`;
- o diretório `~/.omp/`;
- uma linha `omp:` no lock de usuário.

Qualquer um basta. O terceiro torna a camada pegajosa: um update rodado sem os
outros dois a mantém, atualizada. Sem sinal nenhum, a máquina não ganha
`~/.omp/agent/`. O relatório e o dry-run dizem qual sinal decidiu e o que muda em
`~/.omp/agent/`.

Quem roda o reset é o `/anvil-update`, a cada troca de versão. O
`/skill:anvil-boot` só o roda na primeira instalação, quando ainda não há
`~/.claude/anvil.lock`; numa máquina já instalada, ele não toca na camada. Para
pôr a camada numa máquina que ganhou o omp depois do anvil, rode o
`/anvil-update`.

Os seus arquivos em `~/.omp/agent/`, como `config.yml` e os agentes, rules e skills
que você escreveu, ficam fora do lock e o update não os toca. A exceção é o arquivo
seu com o caminho de um arquivo da camada: o dry-run o mostra como colisão e o
update o substitui. Se `~/.omp/agent`, ou uma pasta no caminho da camada, for
symlink ou arquivo, a camada inteira fica com você e nada em `~/.omp/agent/` é
tocado.

## Comandos

- `/skill:anvil-plan <pedido>` conduz o planejamento na mesma janela: grill, spec e
  tickets. Entre uma etapa e outra propõe a próxima, ou um desvio como research ou
  prototype, e só carrega com o seu sim. No fim, indica `/clear` e o `anvil-run`.
- `/skill:anvil-run [NNN] [--parallel N]` implementa a spec ticket a ticket, cada
  ticket num implementer de contexto novo, com o review em dois eixos. Em série
  por padrão; com `--parallel N` e a isolação no modo branch, em levas de até N
  tickets do frontier. Sem número, usa o do branch atual, e fora do branch da spec
  se recusa. Para quando tudo está resolvido ou quando o que sobra está travado, e
  diz o próximo passo. Rodar de novo retoma pelo que está no disco.
- `/skill:anvil-auto [--bench] <pedido>` é o piloto automático: leva um roteiro de
  várias specs do grill ao fechamento, com um sim seu só. Ver "Piloto automático".
- `/skill:anvil-browser-qa` faz o QA de browser. O `anvil-run` o recomenda quando a
  spec tem tela e nunca o dispara, assim como nunca dispara archive nem PR.

A guarda de merge age sozinha: `git merge` de spec com ticket aberto ou sem archive,
e PR aberto pelo `gh` ou pelo `tea` sem archive, são bloqueados com o mesmo motivo
que o Claude Code mostra. Ela só age em projeto anvil, o que tem
`.claude/rules/anvil.md`, e chama o
`guard-spec-merge.sh` da instalação de usuário, em
`~/.claude/skills/anvil-docs/scripts/`. Se ele faltar num projeto anvil, cada
comando do `bash` traz um aviso de que a guarda está desligada, até um
`/anvil-update` reinstalá-lo.

## Piloto automático

O `/skill:anvil-auto <pedido>` leva um pedido que ocupa várias specs do grill ao
fechamento, e você participa uma vez só. Ele tem trava de invocação: roda quando
você o chama, nunca por conta do modelo. Com `--bench`, ou num projeto que tem a
rule da stack do bench, a entrada é a entrevista do `anvil-bench`, para quem não
programa, e não o `anvil-grill`. Nenhum outro sinal liga o modo bench.

**Largada.** Antes de escrever qualquer arquivo, o piloto recusa o perfil do
tracker que não é o `docs/specs`, com a mesma recusa dos condutores; a árvore
suja, porque ele commita no branch base — a `main`, a `master` ou o que a seção
`## Git` de `.claude/rules/anvil.md` declara — e o que é seu entraria num commit
dele; o projeto cujo branch base o resolvedor não decide, com o motivo dele; e,
fora do bench, o `.claude/rules/anvil.md` sem a seção `## Comando de verificação`
com um bloco `bash`, que o `/anvil-boot` grava em projeto novo. Chamado no branch
de uma spec aberta do roteiro, ele retoma a spec do ponto que o disco indica e
depois segue a corrente. Em outro branch, como o de uma spec arquivada ou o de uma
spec que não é de entrada do roteiro, ele recusa.

**O único sim.** O grill, ou a entrevista, cobre o trabalho inteiro: as specs, a
ordem, o escopo, o que fica de fora e o critério de pronto de cada uma. No fim, o
piloto escreve o **roteiro** em `docs/specs/roadmap.md`, valida e mostra o texto,
que no bench é a versão em português simples. A sua confirmação sobre esse texto
é o único sim da execução, e com ela o roteiro é commitado no branch base. Um roteiro
que já existe com entrada inacabada é editado pelo grill, não substituído: uma
entrada inacabada só sai com a sua resposta sobre ela.

**O que ele faz sozinho.** Depois do sim, sem pausa, entrada por entrada, na ordem
do roteiro e só quando as dependências da entrada fecharam:

- abre o branch da spec pelo `new-spec.sh`, saído do branch base, e grava o
  `Spec:` da entrada no branch base;
- roda o `anvil-to-spec` e o `anvil-to-tickets` e responde às pausas deles com a
  opção recomendada pela skill ou, sem recomendação, a mais conservadora;
- despacha os tickets em série, um `anvil-implementer` por ticket, pelo
  `frontier.sh` da `anvil-run`;
- fecha a spec só com `PASS`: todo ticket `resolved`, com a última `Review:` em
  `verdict=pass; p1=none`, e o comando de verificação rodado por ele saindo `0`.
  No bench, o `--reverify` dos gates desta spec e das já fechadas toma o lugar
  do comando;
- fecha com o archive e, pelo forge que o resolvedor dá e pela regra do projeto, o
  merge local no branch base ou o PR aberto pelo `/anvil-open-pr`, no GitHub ou no
  Gitea. Sem remoto ou com `forge: nenhum`, o merge é local; depois do PR, ele envia
  a linha `PR:` ao remoto, confere a árvore e só então volta ao branch base. No
  merge local, quando o branch base andou desde o corte do branch, como
  quando uma spec irmã fechou nesse meio-tempo, ele prepara o merge sem commitá-lo
  e roda a verificação sobre o estado combinado: o comando de verificação ou, no
  bench, o `--reverify`. Com o comando saindo `0` fora do bench, ou, no bench, com
  o `--reverify` na saída que vale o `PASS` pela regra do `GATE.md`, commita o
  merge; com qualquer outra saída, aborta o merge, e a spec fica parada, já
  arquivada no branch, com a pergunta de qual spec cede;
- numa parada técnica, como ticket travado em `round=2`, verificação que falha ou
  implementer bloqueado por fato desconhecido, pesquisa em fontes primárias antes
  de desistir. Abre uma rodada a mais só quando a pesquisa aponta um ticket desta
  spec com evidência que ainda não está nele, o histórico do ticket não mostra
  dois sinais de laço e ele ainda não teve a rodada extra, de nenhuma execução. A
  rodada é registrada no `## Comments` do ticket.

A spec que não fecha sozinha fica aberta no branch dela, e a corrente segue pelas
entradas que não dependem dela. A corrente termina quando não sobra entrada
desbloqueada.

**Onde fica o resultado.** O roteiro, em `docs/specs/roadmap.md`, não guarda
estado: o estado de cada entrada sai do disco, e o `docs/index.md` o mostra. O
relatório, em `docs/specs/report.md`, é escrito à medida que a corrente avança e
commitado no branch base a cada fronteira de spec: o que foi feito, cada pausa
respondida pelo piloto, o que ele decidiu sem você, onde a corrente parou e, por
último, o que ainda espera decisão, cada item como pergunta. O piloto termina
oferecendo um grill novo com essa lista como pauta.

**Uma execução por vez.** O piloto conduz uma execução por vez, spec por spec, e o
estado no disco tem um escritor só. Não há trava em arquivo: rodar duas execuções
no mesmo checkout é erro de operação, e nada o impede.

**O que ele nunca faz:**

- editar o `Entra:`, o `Fica de fora:` ou o `Pronto quando:` de uma entrada, nem
  para adaptar a uma contradição com o código. O escopo e o critério de pronto só
  mudam num grill novo;
- fazer o merge de um PR. Ele abre o PR e para, e o que depende da entrada espera
  o seu merge;
- contornar a guarda de merge. Um bloqueio dela deixa a spec parada, e nenhum
  outro verbo leva o branch para o branch base;
- despachar em paralelo, ou construir duas specs ao mesmo tempo. O `--parallel N`
  é só da `anvil-run`;
- fazer archive ou merge sem `PASS`, ou resolver conflito de merge fora do
  `docs/index.md`;
- perguntar alguma coisa entre o sim e o fim;
- guardar, commitar ou descartar o que você deixou fora de commit.

## Isolação

Com a isolação de tarefas do omp ligada, o `/skill:anvil-run` despacha cada
implementer com `isolated: true`. Ele trabalha numa cópia isolada do checkout, e o
omp traz os commits dele para o branch da spec. O `anvil-run` não adivinha o modo:
o `frontier.sh` lê a configuração com `omp config get task.isolation.enabled` e
`omp config get task.isolation.merge`, na raiz do projeto, e devolve a linha
`isolation`. O relatório abre dizendo se a execução rodou com ou sem isolação.

Para ligar, escreva no `config.yml` da pasta `.omp/` do projeto, ou no
`~/.omp/agent/config.yml` para todos os projetos:

```yaml
task:
  isolation:
    enabled: true
    merge: branch
```

O `merge: branch` é obrigatório. No modo branch, o omp commita o trabalho num
branch `omp/task/<id>` e faz cherry-pick dos commits no branch da spec, um commit
por passo, como sem isolação. O padrão do omp é `patch`, que aplica a mudança sem
commit. Com a isolação ligada no modo patch, o `anvil-run` avisa antes do primeiro
despacho e aponta esta configuração. Ele despacha mesmo assim, e a árvore suja que
o omp deixa o para com `halt`. Para conferir o que o omp lê, rode os dois
`omp config get` acima na raiz do projeto.

A isolação muda a retomada. Sem ela, um implementer que cai deixa a sobra na árvore
da spec, e o `anvil-run` para com `halt` antes do próximo despacho, até você
decidir: `git stash -u` guarda a sobra, um commit seu a mantém, e rodar a skill de
novo retoma. Com ela, a sobra de um implementer que cai ou desiste não chega ao
branch da spec. O omp a deixa no branch `omp/task/<id>` dele, o ticket fica como
estava, e a execução seguinte o despacha de novo. Os branches `omp/task/*` podem
ficar no repositório depois da integração, e o de um trabalho não integrado fica
sempre; apague-os com `git branch -D` quando não precisar mais deles.

O paralelo depende da isolação: só com ela dois implementers rodam ao mesmo tempo
sem dividir a mesma árvore. Com `--parallel N` e a linha `isolation: on`, o
`anvil-run` despacha até N tickets do frontier numa chamada do `task`, e o omp
integra o trabalho de cada um quando ele termina, com o cherry-pick dos commits
dele, um por vez. Se um commit conflita, o omp desfaz só esse e para ali: os
commits anteriores daquele ticket, se houver, ficam no branch da spec, e o
trabalho inteiro fica no `omp/task/<id>`. O ticket volta sem mudar de estado e sai
como pulado, o relatório nomeia o branch, e a execução seguinte o despacha sobre o
que já entrou. Antes dela, você pode desfazer esses commits ou deixá-los. Sem
isolação, ou fora do modo branch, o `anvil-run` recusa o paralelo e segue em
série. O relatório traz quantos tickets estavam prontos a cada rodada, na linha
`ready por rodada`, para você medir se o paralelo compensa.

## O que continua manual no Claude Code e no Codex

Nos dois, a lista de skills é a mesma de sempre e nenhum comando acima existe. O
fluxo segue à mão: `/anvil-grill`, `/anvil-to-spec`, `/anvil-to-tickets`, e depois
uma sessão de `/anvil-implement` por ticket, um de cada vez. O `/anvil-bench`
chamado direto, no Claude Code ou no omp sem o piloto, constrói uma entrada do
roteiro, a que está em andamento ou, sem ela, a do `next:`, e para no fim da
construção, com o archive e o merge listados na entrega para você. O Claude Code
tem a guarda de merge pelo hook do `~/.claude/settings.json`, que o
`/anvil-update` registra. O Codex lê as skills
pelo espelho `~/.agents/skills` e não tem guarda.

## Limites

- O `eval` escapa da guarda. O hook só intercepta o tool `bash`, e um `git merge`
  disparado de dentro do `eval` passa sem conferência. O que se digita no terminal
  também.
- O frontier é em série sem isolação. O paralelo existe sob pedido,
  `--parallel N`, e só com a isolação no modo branch.
- O `task` não escolhe modelo por chamada. O implementer herda o modelo da sessão,
  e as linhas `runners`, `how-explorer`, `how-explainer` e `cross-judge` do `.claude/rules/anvil.md`
  não têm efeito no omp. Para outro modelo, use `task.agentModelOverrides` na
  configuração do omp.
- Os condutores recusam fora do perfil `docs/specs`. O `anvil-plan` e o `anvil-run`
  acham a spec pelo prefixo numérico do branch `{tipo}/{NNN}-{nome}` e leem
  `docs/specs/{NNN}-*/`. Antes disso, leem o título de
  `docs/agents/issue-tracker.md`. Com outro perfil do `anvil-setup` (GitHub, GitLab,
  markdown local), os dois recusam com o nome do perfil achado, e o fluxo segue à
  mão, como no Claude Code. Sem o arquivo, recusam e sugerem o
  `/skill:anvil-setup`. A camada continua instalada com qualquer perfil, com a
  guarda de merge e a rule.

## Como remover a camada à mão

Apague os arquivos da camada e as linhas `omp:` do lock de usuário juntos:

```bash
sed -n 's/^omp: //p' ~/.claude/anvil.lock | while IFS= read -r f; do rm -f ~/.omp/agent/"$f"; done
grep -v '^omp: ' ~/.claude/anvil.lock > ~/.claude/anvil.lock.novo && mv ~/.claude/anvil.lock.novo ~/.claude/anvil.lock
```

As pastas que ficarem vazias em `~/.omp/agent/` podem sair também. Os dois passos
andam juntos. Sem os arquivos e com as linhas, o update seguinte vê a linha `omp:`
e reinstala tudo. Com os arquivos e sem as linhas, eles viram arquivos seus: nenhum
update os atualiza nem remove.

A remoção não sobrevive a uma máquina com omp. Se o próximo `/anvil-update` achar
o binário `omp` no `PATH` ou o diretório `~/.omp/`, a detecção reinstala a camada
como nova, com as linhas `omp:` de volta no lock. Ela só fica fora quando a
máquina não tem nenhum dos dois. O `/skill:anvil-boot`, com o lock já instalado,
não a reinstala.
