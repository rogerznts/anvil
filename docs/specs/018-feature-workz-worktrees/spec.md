# 018 — O workz prepara os worktrees dos implementers, e o anvil o instala e o configura

**Status:** ready-for-agent

O anvil passa a usar o [workz](https://github.com/rohansx/workz) para preparar os
worktrees que a `anvil-implement-spec` cria, um por implementer. O `anvil-update`
instala o binário, o `anvil-boot` configura o projeto, e o worktree de cada
implementer nasce com as dependências e o `.env` do checkout principal, sem
reinstalar nada, e sai no fim da execução.

## Problem Statement

A `anvil-implement-spec`, desde a spec 017, despacha um implementer novo por
ticket, cada um no próprio worktree. No Claude Code, o worktree do subagente sai
do `git worktree add` padrão: nasce sem `node_modules`, sem `vendor`, sem `.env`.
O implementer reinstala as dependências — minutos e gigabytes por ticket num
projeto como o ERP v2 — ou roda a suíte sem elas e falha. E o Claude Code não
remove o worktree de um subagente quando ele termina: a documentação diz que ele
o mantém e não chama o gancho de remoção. Numa spec de dez tickets, sobram dez
worktrees no disco.

O ERP v2 já resolve isso à mão com o workz: o `.workz.toml` dele copia o `.env` e
as configurações locais, e o `bin/worktree` clona as dependências por
copy-on-write e sobe um container por worktree. Esse caminho serve a quem abre um
worktree para trabalhar nele; para um implementer, que só precisa rodar a suíte, o
container por worktree é desperdício — três tickets em paralelo seriam três ERPs
de pé.

No omp, a isolação do `task` já copia o checkout por copy-on-write
(`isolation.backend = auto`, APFS no macOS), mas nada aloca porta ou banco por
worktree quando o projeto precisa disso para os testes.

## Solution

O workz é o comando que prepara o worktree. O anvil o instala, o configura no
projeto e o chama nos dois momentos que importam: quando o worktree do
implementer nasce e quando a execução termina.

- **Instalação.** O `anvil-update` confere se há `workz` no `PATH`. No macOS com
  Homebrew, ausente, instala a release (`brew install rohansx/tap/workz`, hoje a
  `v0.11.0`). Fora disso, não instala: o relatório manda o usuário instalar da
  release `v0.11.0` no GitHub. O código do workz entra em `references/workz` como
  sistema de referência, com pin na tag `v0.11.0`.
- **Configuração do projeto.** O `anvil-boot` pergunta se o projeto usa o workz.
  Com sim, grava a seção `## Worktrees` do `.claude/rules/anvil.md` com o comando
  que prepara o worktree, roda `workz init -y` quando não há `.workz.toml`, e grava
  no `.claude/settings.json` do projeto os ganchos `WorktreeCreate` e
  `WorktreeRemove` do Claude Code. É uma exceção à regra "o boot não escreve hook
  no projeto", registrada num ADR: o gancho de criação substitui a criação de
  worktree inteira, e só o projeto que usa o workz deve tê-lo.
- **O gancho.** Um script do anvil, `anvil-docs/scripts/workz-worktree.sh`, faz as
  duas pontas. `create` lê o payload do Claude Code, cria o worktree no caminho que
  o `workz done` reconhece, roda o comando da seção `## Worktrees` dentro dele e
  imprime só o caminho. `remove` desfaz tudo com o `workz done`. O script usa só
  comandos da `v0.11.0`: o `workz hook claude` dessa versão imprime uma receita que
  não cria o worktree, e o Claude Code a rejeita.
- **Economia, configurável por projeto.** O padrão é `workz sync --quiet`:
  dependências ligadas ao checkout principal e `.env` copiado, sem porta, banco,
  container nem reinstalação. O projeto cujos testes precisam de porta ou banco
  próprios troca o comando por `workz sync --isolated --quiet`. O `post_start` do
  `.workz.toml` não roda pelo `sync`, então o container do ERP não sobe para
  implementer.
- **Criação e limpeza na `implement-spec`.** Quem conduz cria o worktree de cada
  implementer pelo mesmo script, e não por `git worktree add`: na prova da 017 no
  Claude Code, o condutor criou os worktrees pelo Bash, e o gancho
  `WorktreeCreate` não dispara nesse caminho. No passo 9, remove cada um pelo
  script. No omp, a isolação do próprio harness continua criando e removendo; o
  brief do implementer manda rodar o comando da seção `## Worktrees` no início,
  quando o projeto a tem.

## User Stories

1. Como operador, quero que o worktree de cada implementer nasça com as dependências e o `.env` do checkout principal, para o implementer rodar a suíte sem reinstalar nada.
2. Como operador, quero que o worktree de implementer não suba container nem aloque banco por padrão, para três tickets em paralelo não virarem três ambientes de pé.
3. Como operador de um projeto cujos testes precisam de porta ou banco próprios, quero ligar isso na rule do projeto, para o mesmo fluxo servir aos dois casos.
4. Como operador, quero que os worktrees dos implementers saiam no fim da execução, para o disco não acumular um worktree por ticket.
5. Como operador, quero que o `anvil-update` instale o workz quando ele faltar, para não depender de lembrar de instalar à mão.
6. Como operador fora do macOS, quero que o relatório do update me diga de onde instalar o workz, para não ficar sem a peça.
7. Como operador, quero que o `anvil-boot` configure o workz no projeto e me pergunte antes, para nenhum projeto ganhar gancho que não pediu.
8. Como colega que clona o projeto, quero que os ganchos estejam no `.claude/settings.json` versionado, para o meu Claude Code preparar os worktrees como o do resto da equipe.
9. Como mantenedor do anvil, quero o código do workz em `references/workz` com pin, para ler o comportamento da versão que o anvil instala.
10. Como mantenedor, quero que a exceção à regra do boot esteja num ADR, para quem ler a regra saber por que este gancho é diferente.

## Implementation Decisions

### O binário

- Versão: a release `v0.11.0`, a última publicada. A `main` do workz está na
  `0.15.0`, sem release nem Homebrew; o anvil não compila da `main`.
- `reset-install.sh`, depois de instalar o payload: `workz` no `PATH` → relata a
  versão. Ausente, macOS e `brew` no `PATH` → `brew install rohansx/tap/workz`.
  Ausente e outro caso → relata, sem instalar, a URL
  `https://github.com/rohansx/workz/releases/tag/v0.11.0`. O dry-run diz qual dos
  três vai acontecer.
- `references/workz` é submodule com pin na tag `v0.11.0`, **sistema de
  referência**, fora de `sources:` do manifesto: nada do workz é vendorizado.

### A seção do projeto

```markdown
## Worktrees

provisionar: workz sync --quiet
```

- Uma linha de valor, `provisionar:`, com o comando que roda dentro do worktree
  novo, sem prosa junto. O boot propõe `workz sync --quiet` e oferece
  `workz sync --isolated --quiet`.
- Sem a seção, o projeto não usa o workz: o boot não grava ganchos, e o script
  recusa rodar.

### O script `workz-worktree.sh`

- `create`: lê do stdin o JSON do `WorktreeCreate` e tira o nome de `name`, depois
  `branch`, depois o nome-base de `worktree_path`. Branch `worktree-<nome>`, a
  partir do `HEAD` do checkout principal. Caminho
  `<pai do repo>/<repo>--worktree-<nome>`, a convenção que o `workz done` deduz do
  branch. Roda o `provisionar:` dentro do worktree, com toda saída em stderr, e
  imprime só o caminho absoluto, normalizado, no stdout. Falha alta — sem caminho
  no stdout — quando não há seção, não há `workz`, ou o comando sai diferente de
  `0`.
- `remove`: recebe o caminho, pelo JSON do `WorktreeRemove` ou como argumento, e
  roda `workz done <branch> --force --delete-branch`, que remove o worktree, apaga
  o branch e libera a porta alocada.
- Mora em `anvil-docs/scripts/`, ao lado da guarda, e é chamado pelo caminho da
  instalação de usuário: `bash "$HOME/.claude/skills/anvil-docs/scripts/workz-worktree.sh"`.

### Os ganchos no projeto

- O boot grava em `.claude/settings.json` do projeto `hooks.WorktreeCreate` e
  `hooks.WorktreeRemove`, cada um com o comando do script. Mescla com o que o
  arquivo já tem, achando a entrada pelo comando exato; nunca sobrescreve.
- Confere que dispara: um payload de teste no `create` devolve um caminho que
  existe, e o `remove` o apaga.

### A `implement-spec`

- Claude Code e Codex: a diretiva "Integração na `anvil-implement-spec`" do
  `claude_boot.md` manda, num projeto com a seção `## Worktrees`, criar o worktree
  de cada implementer com o `create` do script — o caminho que ele imprime vai no
  brief — e, no passo 9, remover cada um com o `remove`. O gancho cobre o worktree
  que o Claude Code cria sozinho; o de subagente sai pelo `remove`, porque o
  Claude Code não chama o `WorktreeRemove` para ele.
- omp: a rule de harness da camada manda o brief do implementer rodar o
  `provisionar:` no próprio worktree antes de começar, quando o projeto tem a
  seção. A isolação do omp continua criando e removendo o worktree.
- Nenhuma mudança no texto vendorizado da `implement-spec`.

## Testing Decisions

- O script se prova em repositório descartável: payload de teste no `create`
  devolve caminho existente, com `.env` e dependências; com o `provisionar`
  isolado, o `.env.local` tem o bloco gerenciado; o `remove` apaga worktree e
  branch; sem seção ou sem `workz`, o `create` sai diferente de `0` e não imprime
  caminho.
- O update se prova no dry-run e na execução, num HOME dev, nos três casos de
  presença do `workz`.
- O critério final é uma prova no Claude Code real: a `implement-spec` sobre uma
  spec de dois tickets independentes num projeto com `node_modules` e a seção
  `## Worktrees`. Cada implementer roda a suíte no próprio worktree sem instalar
  dependência, e no fim nenhum worktree de implementer sobra.

## Out of Scope

- Compilar o workz da `main` ou da `0.15.0`.
- Instalar o workz fora do macOS com Homebrew.
- Subir container ou banco por implementer; o `post_start` do projeto continua
  sendo do `workz start` humano.
- O MCP do workz, o `workz run` e o `workz preview`.
- Mudar o texto vendorizado da `anvil-implement-spec`.

## Further Notes

- O `workz hook claude` da `v0.11.0` imprime `workz sync --isolated --quiet` como
  gancho `WorktreeCreate`; o Claude Code espera que o gancho crie o worktree e
  imprima o caminho, então a receita falha. O defeito é o #18 do workz, corrigido
  na `main` com o `workz claude-hook`. Quando houver release com ele, o script do
  anvil pode dar lugar ao comando nativo.
- O ERP v2 continua com o próprio `bin/worktree` para o worktree humano; o
  implementer do anvil usa só o `sync`.
