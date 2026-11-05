# ADR-0025 — O gancho de worktree do workz fica no projeto, não no usuário

- Status: aceito
- Data: 2026-11-04
- Origem: [spec 018](../../specs/archive/018-feature-workz-worktrees/spec.md), o workz prepara os worktrees dos implementers
- Revê em parte o [ADR-0013](./adr-0013-toolkit-instalado-por-usuario.md): o boot volta a escrever um hook no `.claude/settings.json` do projeto, só para o worktree

## Contexto

O ADR-0013 levou o toolkit para a instalação de usuário, e com ele a guarda de
merge: o hook dela mora no `~/.claude/settings.json` e reconhece o projeto anvil
pela rule `anvil.md`. Desde então o boot não escreve hook nem script no projeto.

A spec 018 liga o workz aos worktrees que a `anvil-implement-spec` cria no Claude
Code. O ponto de ligação é o gancho `WorktreeCreate`, e ele não se comporta como o
`PreToolUse` da guarda: **substitui** a criação de worktree inteira. Com ele
configurado, o Claude Code não roda o `git worktree add` nem processa o
`.worktreeinclude`; quem cria o worktree é o gancho, e sem caminho no stdout a
criação falha.

Instalado por usuário, o gancho valeria para todo projeto da máquina, inclusive os
que não são do anvil ou não usam o workz. Nesses, ele teria de imitar o padrão do
Claude Code — o caminho em `.claude/worktrees/`, o nome do branch, a cópia do
`.worktreeinclude` —, e essa imitação quebra em silêncio quando o Claude Code muda
o padrão.

## Decisão

**O `anvil-boot` grava os ganchos `WorktreeCreate` e `WorktreeRemove` no
`.claude/settings.json` do projeto, e só quando o projeto usa o workz.** Usar o
workz é ter a seção `## Worktrees` no `.claude/rules/anvil.md`, que o boot grava
depois de perguntar. O comando dos ganchos chama o script da instalação de
usuário, `anvil-docs/scripts/workz-worktree.sh`, pelo caminho em `$HOME`, como a
guarda: o projeto guarda a ligação, e o comportamento vem do toolkit instalado.

O boot mescla com o que o arquivo tem, acha a entrada pelo comando exato e nunca
sobrescreve. O `.claude/settings.json` é arquivo do projeto, versionado com ele
como `.claude/rules/`, então a equipe que clona o projeto recebe os ganchos.

## O que o ADR-0013 perde

- **A regra "o boot não escreve hook no projeto"** passa a ter uma exceção nomeada:
  os dois ganchos de worktree, num projeto com a seção `## Worktrees`. A guarda de
  merge continua por usuário.

## Alternativas descartadas

- **Gancho por usuário, pelo `anvil-update`.** Alcança toda a máquina e obriga o
  script a reproduzir o padrão do Claude Code fora dos projetos com workz.
- **O `workz hook claude --install` da `v0.11.0`.** A receita dessa versão põe
  `workz sync` como `WorktreeCreate`; o comando não cria o worktree nem imprime o
  caminho, e o Claude Code rejeita a criação.

## Consequências

**A favor.** Só o projeto que pediu tem o gancho. A equipe recebe a ligação pelo
git. O comportamento muda com o `/anvil-update`, sem tocar no projeto.

**Contra.** Quem clona sem o anvil instalado tem um gancho que chama um script
inexistente, e a criação de worktree no Claude Code falha nesse projeto até instalar
o toolkit; a seção de instalação do `anvil.md` diz como.
