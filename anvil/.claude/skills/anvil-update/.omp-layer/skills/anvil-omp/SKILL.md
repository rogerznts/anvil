---
name: anvil-omp
description: Manual da camada omp do anvil. O que ela instala em .omp/, como a detecção decide, os comandos, a isolação, os limites e como removê-la.
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

A camada omp é o que o anvil instala em `.omp/` para isso: o hook que traz a guarda
de merge para o omp, a rule que traduz o vocabulário do Claude Code nas skills, o
agente que implementa um ticket, e as skills `anvil-plan`, `anvil-run` e esta. A
lista exata do que está instalado neste projeto são as linhas `omp:` do
`.claude/anvil.lock`, uma por arquivo, com o caminho relativo a `.omp/`.

## Como a detecção decide

O `/anvil-update` e o `/skill:anvil-boot` instalam a camada sem perguntar quando
acham um destes sinais:

- o binário `omp` no `PATH`;
- o diretório `~/.omp/`;
- uma linha `omp:` no lock.

Qualquer um basta. O terceiro torna a camada pegajosa: um colega sem omp roda o
update e a camada fica, atualizada. Sem sinal nenhum, o projeto não ganha `.omp/`.
O relatório e o dry-run dizem qual sinal decidiu e o que muda em `.omp/`.

Os seus arquivos em `.omp/`, como `config.yml` e os agentes, rules e skills que
você escreveu, ficam fora do lock e o update não os toca. A exceção é o arquivo seu
com o caminho de um arquivo da camada: o dry-run o mostra como colisão e o update o
substitui. Se `.omp`, ou uma pasta no caminho da camada, for symlink ou arquivo, a
camada inteira fica com você e nada em `.omp/` é tocado.

## Comandos

- `/skill:anvil-plan <pedido>` conduz o planejamento na mesma janela: grill, spec e
  tickets. Entre uma etapa e outra propõe a próxima, ou um desvio como research ou
  prototype, e só carrega com o seu sim. No fim, indica `/clear` e o `anvil-run`.
- `/skill:anvil-run [NNN]` implementa a spec ticket a ticket, em série, cada ticket
  num implementer de contexto novo, com o review em dois eixos. Sem número, usa o
  do branch atual, e fora do branch da spec se recusa. Para quando tudo está
  resolvido ou quando o que sobra está travado, e diz o próximo passo. Rodar de novo
  retoma pelo que está no disco.
- `/skill:anvil-browser-qa` faz o QA de browser. O `anvil-run` o recomenda quando a
  spec tem tela e nunca o dispara, assim como nunca dispara archive nem PR.

A guarda de merge age sozinha: `git merge` de spec com ticket aberto ou sem archive,
e `tea pr create` sem archive, são bloqueados com o mesmo motivo que o Claude Code
mostra.

## Isolação

Com a isolação de tarefas do omp ligada, o `/skill:anvil-run` despacha cada
implementer com `isolated: true`. Ele trabalha numa cópia isolada do checkout, e o
omp traz os commits dele para o branch da spec. O `anvil-run` reconhece a isolação
pelo campo `isolated` do `task`, que o omp só oferece com a isolação ligada e fora
do modo plan, e o relatório abre dizendo se a execução rodou com ou sem ela.

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
commit: a árvore fica suja, o `anvil-run` para com `halt` e o relatório aponta esta
configuração.

A isolação muda a retomada. Sem ela, um implementer que cai deixa a sobra na árvore
da spec, e o `anvil-run` para com `halt` antes do próximo despacho, até você
decidir: `git stash -u` guarda a sobra, um commit seu a mantém, e rodar a skill de
novo retoma. Com ela, a sobra de um implementer que cai ou desiste não chega ao
branch da spec. O omp a deixa no branch `omp/task/<id>` dele, o ticket fica como
estava, e a execução seguinte o despacha de novo. Os branches `omp/task/*` ficam no
repositório depois da integração; apague-os com `git branch -D` quando não
precisar mais deles.

O paralelo depende da isolação: só com ela dois implementers rodam ao mesmo tempo
sem dividir a mesma árvore. Hoje o `anvil-run` segue em série nos dois modos.

## O que continua manual no Claude Code e no Codex

Nos dois, a lista de skills é a mesma de sempre e nenhum comando acima existe. O
fluxo segue à mão: `/anvil-grill`, `/anvil-to-spec`, `/anvil-to-tickets`, e depois
uma sessão de `/anvil-implement` por ticket, um de cada vez. O Claude Code tem a
guarda de merge pelo hook do `.claude/settings.json`. O Codex lê as skills pelo
espelho `.agents/skills` e não tem guarda.

## Limites

- O `eval` escapa da guarda. O hook só intercepta o tool `bash`, e um `git merge`
  disparado de dentro do `eval` passa sem conferência. O que se digita no terminal
  também.
- O frontier é em série. O `anvil-run` implementa um ticket por vez, mesmo quando
  dois tickets não dependem um do outro.
- O `task` não escolhe modelo por chamada. O implementer herda o modelo da sessão,
  e as listas `runners`, `how-critics` e `cross-judge` do `.claude/rules/anvil.md`
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

Apague os arquivos da camada e as linhas `omp:` do lock no mesmo commit:

```bash
sed -n 's/^omp: //p' .claude/anvil.lock | while IFS= read -r f; do rm -f ".omp/$f"; done
grep -v '^omp: ' .claude/anvil.lock > .claude/anvil.lock.novo && mv .claude/anvil.lock.novo .claude/anvil.lock
```

As pastas que ficarem vazias em `.omp/` podem sair também. Os dois passos andam
juntos. Sem os arquivos e com as linhas, o update seguinte vê a linha `omp:` e
reinstala tudo. Com os arquivos e sem as linhas, eles viram arquivos seus: numa
máquina sem omp, nenhum update os atualiza nem remove.

A remoção não sobrevive a uma máquina com omp. Se quem rodar o próximo
`/anvil-update` ou `/skill:anvil-boot` tiver o binário `omp` no `PATH` ou o
diretório `~/.omp/`, a detecção acha o sinal e reinstala a camada como nova, com as
linhas `omp:` de volta no lock. Ela só fica fora nos updates rodados em máquina sem
esses dois sinais.
