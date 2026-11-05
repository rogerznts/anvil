---
description: "Vocabulário do Claude Code nas skills do anvil, traduzido para as primitivas do omp."
alwaysApply: true
---

# Vocabulário das skills no omp

As skills e as diretivas do anvil foram escritas para o Claude Code. No omp, leia
assim o que elas mandam fazer:

- "Skill tool", "Call the Skill tool with X" e `/anvil-x` citado dentro de uma
  skill ou das diretivas: leia a skill com o tool `read` em `skill://X` e siga-a.
  Vale para a cauda de roteamento das diretivas: invocar o `anvil-next` é ler
  `skill://anvil-next` e seguir o formato dele.
- "sub-agent", "subagent", "Task" e "Agent": o tool `task`. Quando a skill pede só
  leitura, como achar um fato, explorar ou `readonly`, use o agente `scout`.
- `AskUserQuestion`: o tool `ask`.
- `.claude/rules/*.md`, que o Claude Code carrega sozinho e o omp não: antes da
  primeira resposta da sessão, inclusive quando ela começa por `/skill:`, leia
  cada arquivo com `read`. É deles que vem o idioma de comunicação.

## A `anvil-implement-spec` no omp

O worktree por implementer e o merger da `anvil-implement-spec` são primitivas do
omp, e não passos a executar à mão. Antes do primeiro despacho, leia o modo da
isolação na raiz do projeto, com `omp config get task.isolation.enabled` e
`omp config get task.isolation.merge`.

- **Quem implementa.** Cada implementer é um item do `task` com o agente padrão,
  `task`, nunca um agente que rode review: o implementer recebe o ticket, chama a
  `anvil-tdd`, commita e não grava linha `Review:` nem mexe no `Status:` do
  ticket. Quem fecha os tickets é o passo 8, e o review é só o do passo 7, sobre a
  spec.
- **Isolação ligada no modo branch** (`true` e `branch`): "each in its own
  worktree on its own branch" é o `task` com `isolated: true` em **todo** item,
  um implementer por ticket do frontier. O omp copia o checkout a partir do `HEAD`
  do branch da spec e commita o trabalho num branch `omp/task/<id>`. O "merger
  subagent" é a integração do omp: quando um implementer termina, o omp faz o
  cherry-pick dos commits dele no branch da spec, um por vez. Não despache
  merger. O implementer não faz merge da ponta do branch de integração antes de
  reportar: o omp aplica os commits sobre a ponta atual, e um commit de merge
  entraria no cherry-pick.
- **Worktree pelo workz.** Num projeto com a seção `## Worktrees` no
  `.claude/rules/anvil.md`, o brief de cada implementer isolado manda rodar o
  comando da linha `provisionar:` na raiz da cópia isolada, antes de começar o
  ticket. A cópia do omp já traz as dependências; o comando acrescenta o que o
  projeto pediu, como o bloco de portas e banco do `.env.local`. A isolação do
  omp continua criando e descartando a cópia; não chame o `workz-worktree.sh`.
- **Sem o modo branch** (isolação desligada, ou ligada no modo `patch`): um item
  por chamada do `task`, sem `isolated`, e a próxima chamada só depois do
  resultado da anterior. Cada implementer trabalha na árvore do branch da spec e
  commita o próprio trabalho nele antes de reportar. Não há worktree a conferir,
  merge a fazer nem worktree a limpar.
- **Nunca dois implementers na mesma chamada sem `isolated: true`.** Dividiriam a
  árvore, o banco e o gate, e um commit levaria o trabalho do outro.
- **Conflito na integração.** O resultado do `task` traz `Branch merge failed:
  omp/task/<id>`. O ticket não entrou: ele volta ao frontier e é despachado de
  novo, num implementer novo, sobre o branch da spec que já tem o que entrou. Os
  commits dele anteriores ao conflito podem já estar no branch da spec, e o
  trabalho inteiro fica no `omp/task/<id>`. Não resolva o conflito à mão.
- **Limpeza.** O omp descarta a cópia isolada. Os branches `omp/task/*` já
  integrados saem com `git branch -D`; o de um trabalho não integrado fica, e o
  relatório o nomeia.
